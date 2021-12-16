/**
 * in questo file ci sono un paio di funzioini per
 * raccogliere e salvare le varie squadre della serie a
 */

const JSSoup = require('jssoup').default;

import {getPageHtml} from "../../../utils/utils";
import {TeamEnum, TeamEnumModel} from "../bricks/team_enum"

/**
 * funzoine per pulire la tabella della squadre
 */
export async function cleanTeams(){
	await TeamEnumModel.deleteMany({});
}

/**
 * funzione che raccogle tutte le possibili squadre
 */
export async function getTeams(): Promise<Array<string>>{

	let team_source = "http://www.legaseriea.it/en/serie-a/league-table";
	let teams: Array<string> = [];
	let page_source = await getPageHtml(team_source);

	let soup = new JSSoup(page_source);

	let tabella = soup.find("table",{class:["classifica","tabella"]});
	for(let riga of tabella.find("tbody").findAll("tr")){
		let first_column = riga.findAll("td")[0];
		let raw_team_name = first_column.text as string;

		let team_name:string = raw_team_name.split(" ").filter( (part:string)=>{
			return part.length > 3;
		}).join(" ");

		teams.push(team_name.toUpperCase());
	}
	return teams;
}

/**
 * funzione che salva tutte le squadre
 */
export async function saveTeams(){
	for(let team of await getTeams())
		await TeamEnumModel.create({
			name: team
		});
}

