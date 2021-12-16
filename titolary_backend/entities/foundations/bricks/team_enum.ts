import { prop, index, staticMethod, getModelForClass } from '@typegoose/typegoose';

/**
 * questa classe serve solo a fare una grande lista di squadre
 * così ho dei riferimenti standard quando devo costruire i giocatori
 */
export class TeamEnum{
	@prop()
	public name: string;

	constructor(name: string){
		this.name = name
	}

	public get stringKey(): string{
		return this.name;
	}
}

export const TeamEnumModel = getModelForClass(TeamEnum);
