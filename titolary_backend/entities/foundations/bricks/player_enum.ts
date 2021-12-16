import { prop, Typegoose, instanceMethod, staticMethod, getModelForClass } from '@typegoose/typegoose';
/**
 * questa classe la uso solo per poter costruire una mega lista di nomi 
 * di giocatori, così ho un set standard di nomi e 
 * quando andrò in giro per le fonti, dovrò solo cercare quale nome 
 * assomiglia di piu a quello che sto guardando
 */
export class PlayerEnum {
	@prop()
	public name: string;

	constructor(name: string){
		this.name = name
	}

	public get stringKey(): string{
		return this.name;
	}
}

export const PlayerEnumModel = getModelForClass(PlayerEnum);
