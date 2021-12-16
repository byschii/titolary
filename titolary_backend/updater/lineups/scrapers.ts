//const puppeteer = require('puppeteer');
const JSSoup = require('jssoup').default;
const mongoose = require('mongoose');

import {Map} from "../../utils/map_class";
import {Source} from "../../entities/suppliers/source";

import {PlayerData, PlayerDataModel} from "../../entities/foundations/bricks/player_data"; 
import {TeamEnum, TeamEnumModel} from "../../entities/foundations/bricks/team_enum";
import {getPageHtml, fuzzySearchInCollection, fuzzySearchInArray} from "../../utils/utils";



export abstract class Scraper{
	private _source: Source;
	public _soup ?: any;
	public _result = new Map<string[]>();

	constructor(source: Source){
		this._source = source;
	}

	public abstract async scrape(): Promise<void>;

	public async initFields(): Promise<void>{
		let teamList = await TeamEnumModel.find({})

		for(let team of teamList)
			this._result.add(
				team.name, new Array<string>());

		this._soup = new JSSoup( await getPageHtml(this.source.scrapeLink) );
	}

	public async findRegisteredPlayer(unknownPlayer: [string,string,string]): Promise<PlayerData>{

		let unknownPlayerSanitized = unknownPlayer.map(
			//(part:string)=>{ return part.replace(/[^a-zA-Z ]+/g, '') }
			(part:string)=>{ return part.replace('&#39', '\'') }
		);
		let teamId = await TeamEnumModel.findOne({name:unknownPlayerSanitized[0]})
		let playerInTeam = await PlayerDataModel.find({team:teamId}).populate("player").populate("team");

		let result = fuzzySearchInArray(playerInTeam,
			["player.name"], unknownPlayerSanitized[1],2
			)

		if(result[0] !== undefined)
			return result[0]

		throw "Player "+unknownPlayer[1]+" NOT FOUND";
	}

	public putPlayerInResult(p:PlayerData) : void{
		if(p.team !== undefined){
			this._result.get(
				(p.team as TeamEnum).name
			).push( (p as any).player._id as string );
		}else
			throw "Team Undefined";
	}

	public get source() : Source {
		return this._source
	}
}


export class Fantacalcio extends Scraper{
	public async scrape(): Promise<void> {
		await super.initFields();


		let roi = this._soup.findAll('div', {
			'class':'tab-content',
			'id':'sqtab'
			})[0]; // qui ci sono tutte le squadre

		
		for(let match of roi.findAll("div", {'class':'fade'})){
			let squadre : string = match.attrs.id;

			let squadraCasa = await fuzzySearchInCollection(
				TeamEnumModel, [], ["name"], squadre.split('-')[0], 1
				);
			let squadraOspite = await fuzzySearchInCollection(
				TeamEnumModel, [], ["name"], squadre.split('-')[1], 1
				);
			
			let giocatoriHtml = match.contents[0].contents[1].contents[2];
			let giocatoriCasaHtml = giocatoriHtml.contents[1];
			let giocatoriOpsitiHtml = giocatoriHtml.contents[2];

			// scorro tutti i giocaori di casa
			for(let playerHtml of giocatoriCasaHtml.contents){
				let playerName: string = playerHtml.contents[1].contents[0].text;
				let playerRole: string = playerHtml.contents[0].text;
				let unknownPlayer: [string,string,string] = [
					squadraCasa[0].name,
					playerName,
					""//playerRole
					];
				
				try{
					let registeredPlayer = await this.findRegisteredPlayer(unknownPlayer);
					this.putPlayerInResult(registeredPlayer);
				}catch{
					console.log("fantacalcio non ha trovato", unknownPlayer);
				}
				
			}

			// scorro tutti gli ospiti
			for(let playerHtml of giocatoriOpsitiHtml.contents){
				let playerName: string = playerHtml.contents[1].contents[0].getText();
				let playerRole: string = playerHtml.contents[0].text;
				let unknownPlayer: [string,string,string] = [
					squadraOspite[0].name,
					playerName,
					""//playerRole
					];

				try{
					let registeredPlayer = await this.findRegisteredPlayer(unknownPlayer);
					this.putPlayerInResult(registeredPlayer);
				}catch{
					console.log("fantacalcio non ha trovato", unknownPlayer);
				}
			}

		}
	}
}


export class SosFanta extends Scraper{
	async scrape(): Promise<void> {
		await super.initFields();
		let roi = this._soup.findAll('div', {class:'match-likely'})

		for(let partita of roi ){
			let squadreHtml = partita.find('div', {class:'match-likely__team-names'});
			let squadraCasa:string = squadreHtml.contents[0].contents[1].text.trim();
			let squadraOspite:string = squadreHtml.contents[2].contents[1].text.trim();


			let teamCasa = await fuzzySearchInCollection(
				TeamEnumModel, [], ["name"], squadraCasa, 1);
			let teamOspite = await fuzzySearchInCollection(
				TeamEnumModel, [], ["name"], squadraOspite, 1);

			let giocatoriHtml = partita.find('table', {class:'match-players'});
			let roleCounter : number = 0;
			for(let playerHtml of giocatoriHtml.findAll('tr',{class:'match-players__row'})){
				// parte casa
				let playerNameCasa: string = playerHtml.contents[0].text;
				let unknownPlayerCasa : [string,string,string]= [
					teamCasa[0].name,
					playerNameCasa.trim(),
					""//Math.floor(roleCounter/3));
					];
				
				try{
					let registeredPlayerCasa = await this.findRegisteredPlayer(unknownPlayerCasa);
					this.putPlayerInResult(registeredPlayerCasa);
				}catch{
					console.log("Sosfanta non ha trovato ", unknownPlayerCasa );
				}
				// parte ospiti
				let playerNameOspite: string = playerHtml.contents[1].text;
				let unknownPlayerOspite : [string,string,string]= [
					teamOspite[0].name,
					playerNameOspite.trim(), 
					""//Math.floor(roleCounter/3));
					];

				try{
					let registeredPlayerOspite = await this.findRegisteredPlayer(unknownPlayerOspite);
					this.putPlayerInResult(registeredPlayerOspite);
				}catch{
					console.log("Sosfanta non ha trovato", unknownPlayerOspite );
				}
				

				roleCounter++;
			}
		}
	}
}


export class Gazzetta extends Scraper{
	async scrape(): Promise<void> {
		await super.initFields();

		let roi = this._soup.findAll('div',{class:'matchFieldContainer'});

		for(let partita of roi){
			let squadreHtml = partita.contents[2];
			let giocatoriHtml = partita.contents[3];
			
			let casa = await fuzzySearchInCollection(
				TeamEnumModel,  [], ["name"], squadreHtml.contents[0].text.trim(), 1);
			let ospiti = await fuzzySearchInCollection(
				TeamEnumModel, [], ["name"], squadreHtml.contents[1].text.trim(), 1);

			let listaGiocatoriCasa = giocatoriHtml.findAll('ul',{class:'team-players'})[0];
			let listaGiocatoriOspiti = giocatoriHtml.findAll('ul',{class:'team-players'})[1];
			
			//giocari casa
			let roleCounter:number = 0;
			for(let giocatore of listaGiocatoriCasa.findAll('span',{class:'team-player'})){
				let unknownPlayer : [string,string,string] = [
					casa[0].name,
					giocatore.text,
					""//Math.floor(roleCounter/3));
					];

				try{
					let registeredPlayer = await this.findRegisteredPlayer(unknownPlayer);
					this.putPlayerInResult(registeredPlayer);
				}catch{
					console.log("gazzetta non ha trovato ", unknownPlayer);
				}
				roleCounter++;
			}
			
			roleCounter = 0;
			for(let giocatore of listaGiocatoriOspiti.findAll('span',{class:'team-player'})){
				let unknownPlayer : [string,string,string] = [
					ospiti[0].name,
					giocatore.text,
					""//Math.floor(roleCounter/3));
					];


				try{
					let registeredPlayer = await this.findRegisteredPlayer(unknownPlayer);
					this.putPlayerInResult(registeredPlayer);
				}catch{
					console.log("gazzetta non ha trovato ", unknownPlayer);
				}
				roleCounter++;
			}

		}
	}
}


export class SkySport extends Scraper{
	public async scrape(): Promise<void> {
		await super.initFields();

		for(let match of this._soup.findAll('div', {class: 'pf_singolo_match_lista'})){
			
			let teamsHtml = match.find('div', {class: 'header'});
			let team:string[] = teamsHtml.text.trim().split('\n');

			let teamCasa = await fuzzySearchInCollection(
				TeamEnumModel,  [], ["name"], team[1].trim(), 1);
			let teamOspiti = await fuzzySearchInCollection(
				TeamEnumModel,  [], ["name"], team[3].trim(), 1);


			let playerList = match.findAll('ul', {class: 'playerslist'});
			//ciclo casa
			for(let playerHtml of playerList[0].findAll('span', {class: 'name'})){
				let unknownPlayer : [string,string,string] = [
					teamCasa[0].name,
					playerHtml.text,
					""
					];
				
				try{
					let registeredPlayer = await this.findRegisteredPlayer(unknownPlayer);
					this.putPlayerInResult(registeredPlayer);
				}catch{
					console.log("skysport non ha trovato", unknownPlayer );
				}
				
			}

			//ciclo ospiti
			for(let playerHtml of playerList[1].findAll('span', {class: 'name'})){
				let unknownPlayer : [string,string,string] = [
					teamOspiti[0].name,
					playerHtml.text,
					""
					];
				
					try{
						let registeredPlayer = await this.findRegisteredPlayer(unknownPlayer);
						this.putPlayerInResult(registeredPlayer);
					}catch{
						console.log("skysport non ha trovato", unknownPlayer );
					}
			}
		}
	}
}

