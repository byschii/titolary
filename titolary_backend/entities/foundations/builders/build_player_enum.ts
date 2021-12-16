/**
 * in questo file ci sono un paio di funzioini per gestire la tabella
 * con i nomi standard dei giocatori
 * 
 * - una funzione fa pulizia
 * - una funzione prende tutti i nomi dei giocatori dal sito della lega
 * - una funzione prende tutti i nomi e con essi crea-salva degli oggetti nel db
 */

const JSSoup = require('jssoup').default;

import {getPageHtml} from "../../../utils/utils";
import {PlayerEnum, PlayerEnumModel} from "../bricks/player_enum";
import {getTeams} from "./build_team_enum";

/**
 * pulisce la tabella degli enum dei giocatori
 */
export async function cleanPlayers(){
	await PlayerEnumModel.deleteMany({});
}


export async function getPlayers(): Promise<Array<string>>{
	let names: Array<string> = [];
	for(let team_name of await getTeams()){
		team_name = team_name.toLowerCase().trim().replace(" ","-");
		let player_source_format = `http://www.legaseriea.it/it/serie-a/teams/${team_name}/team`;

		let soup = new JSSoup(await getPageHtml(player_source_format));
		let tabella = soup.findAll("table",{class:["tabella","colonne9"]})[0];
		for(let riga of tabella.findAll("tr")){
			// devo saltare l intestazione
			let nome = riga.findAll("td")[1]
			if(nome !== undefined){
				names.push(nome.text.trim());
			}
		}
	}
	return names;
}

/**
 * crea la tabella degli enum dei giocatori
 */
export async function savePlayers(){
	for(let player_name of await getPlayers())
		await PlayerEnumModel.create({
			name: player_name
		});
}