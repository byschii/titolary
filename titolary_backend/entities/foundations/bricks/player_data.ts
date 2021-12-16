import { prop, index, staticMethod, Ref, getModelForClass } from '@typegoose/typegoose';

import {TeamEnum, TeamEnumModel} from "./team_enum";
import {PlayerEnum, PlayerEnumModel} from "./player_enum";

/**
 * questa classe sostanzailmente è quella che fa il carico piu pensate
 * all inizio la uso per abbinare i nomi dei giocatori a squadra e ruolo
 * poi passa un altro script che deve riempire le informazioni sulla titolarita 
 */
export class PlayerData {
	@prop({ref:TeamEnum})
	public team: Ref<TeamEnum>;

	@prop({ref: PlayerEnum})
	public player: Ref<PlayerEnum>;

	@prop({ validate: (value:string) => value.length == 1})
	public role: string;

	@prop({ validate: (arr:string) => arr.length <= 3})
	public starting: [string,boolean][];
	
	constructor(
		team: TeamEnum|Ref<TeamEnum>,
		player: PlayerEnum|Ref<PlayerEnum>,
		role: string){
		this.team = team;
		this.player = player;
		this.role = role;
		this.starting = [];
	}
}

export let PlayerDataModel = getModelForClass(PlayerData);

