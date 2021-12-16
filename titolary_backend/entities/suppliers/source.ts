import { prop, Typegoose, instanceMethod, staticMethod, getModelForClass } from '@typegoose/typegoose';

export class Source {
	@prop()
	public name: string;
	@prop()
	public link: string;
	@prop()
	public scrapeLink : string;
	@prop()
	public abbreviation: string;

	constructor(name: string, link: string, scrapeLink: string, abbreviation:string){
		this.name = name;
		this.link = link;
		this.scrapeLink = scrapeLink;
		this.abbreviation = abbreviation;
	}

}

export const SourceModel = getModelForClass(Source);



