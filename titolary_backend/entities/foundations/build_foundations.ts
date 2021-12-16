const mongoose = require('mongoose');

import {savePlayers,    cleanPlayers   } from "./builders/build_player_enum" ;
import {saveTeams,      cleanTeams     } from "./builders/build_team_enum"   ;
import {savePlayerData, cleanPlayerData} from "./builders/build_player_data" ;
import {saveTeamData,   cleanTeamData  } from "./builders/build_team_data"   ;

import {getMongoUrl} from "../../utils/utils";

/**
 * questa classe serve a inizializzare tutti i pezzi fondamentali
 * ovvero i nomi dei giocatoi, i nomi delle squadre e gli abbinamenti
 * giocatore + squadra + ruolo
 * 
 * NOTA BENE: 'savePlayerData' per funzionare ha bisogno che le squadre e i 
 * giocatori siano gia stati scritti su db
 */
async function setup(){
	mongoose.connect(
		getMongoUrl()+'/titolari', {
			useUnifiedTopology: true,
			useNewUrlParser: true,
			useFindAndModify: false
		});

	await Promise.all([
		cleanPlayerData(),
		cleanTeams(),
		cleanPlayers(),
		cleanTeamData()
	]);

	await Promise.all([
		saveTeams(),
		savePlayers()
		]);
	await Promise.all([
		savePlayerData(),
		saveTeamData()
	]);
	
	mongoose.connection.close();
}


setup();

