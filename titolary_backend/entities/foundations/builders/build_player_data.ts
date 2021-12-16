/**
 * in questo file ci sono un paio di funzioni che servono ad abbinare 
 * i vari giocatori alle varie squadre
 */
const JSSoup = require('jssoup').default;

import {getPageHtml} from "../../../utils/utils";
import {getTeams} from "./build_team_enum";
import {PlayerEnum, PlayerEnumModel} from "../bricks/player_enum";
import {TeamEnum, TeamEnumModel} from "../bricks/team_enum"
import {PlayerData,PlayerDataModel} from "../bricks/player_data";

export async function cleanPlayerData(){
	await PlayerDataModel.deleteMany({});
}

/**
 * questa funzoine va sul sito della legaserieA
 * e crea delle terne di nomeSquadra, nomeGiocatore, ruolo
 * che poi verran salvati e combinati
 */
async function getTeamPlayerRole(): Promise<Array<[string,string,string]>>{
	let team_player_role_tuple: Array<[string,string,string]> = [];
	for(let team_name of await getTeams()){
		team_name = team_name.toLowerCase().trim().replace(" ","-");
		let player_source_format = `http://www.legaseriea.it/it/serie-a/teams/${team_name}/team`;

		let soup = new JSSoup(await getPageHtml(player_source_format));
		let tabella = soup.findAll("table",{class:["tabella","colonne9"]})[0];
		for(let riga of tabella.findAll("tr")){
			// devo saltare l intestazione
			let nome = riga.findAll("td")[1];
			if(nome !== undefined){
				let role:string = riga.findAll("td")[3].text;
				team_player_role_tuple.push([
					team_name.replace("-"," ").toUpperCase(),
					nome.text.trim(),
					role.trim().charAt(0)
					]);
			}
		}
	}

	return team_player_role_tuple;
}

/**
 * questa funzione prende le varie terne di 'getTeamPlayerRole'
 * e usa i dati per creare le istanze di 'PlayerData' che verrano salvate 
 */
export async function savePlayerData(){
	for(let player_tuple of await getTeamPlayerRole()){
		let t : TeamEnum|null; 
		let p : PlayerEnum|null;

		// siccome la fonte dei nomi e la lega, vado direttamente
		// a cercare il nome senza fare troppo arzigogoli
		[t,p] = await Promise.all([
			TeamEnumModel.findOne({name: player_tuple[0]}),
			PlayerEnumModel.findOne({name: player_tuple[1]})
			]); 

		if(t!==null && p!==null && player_tuple[2].length == 1)
			await PlayerDataModel.create({
				team:t,
				player:p,
				role:player_tuple[2]
			});

	}
}