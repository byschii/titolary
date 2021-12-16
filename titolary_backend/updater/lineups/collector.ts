const mongoose = require('mongoose');
const fs = require('fs');

import { Scraper, Fantacalcio, SosFanta, Gazzetta, SkySport } from './scrapers';
import {Source, SourceModel} from "../../entities/suppliers/source";
import {PlayerDataModel} from "../../entities/foundations/bricks/player_data";
import {getMongoUrl} from "../../utils/utils";


async function run() {

	let sources: Array<Source|null> = await Promise.all([
			SourceModel.findOne({abbreviation:"FANT"}),
			SourceModel.findOne({abbreviation:"SOSF"}),
			SourceModel.findOne({abbreviation:"GAZZ"}),
			SourceModel.findOne({abbreviation:"SKYS"})
		]);

	let scrapers: Array<Scraper> = [];
	sources[0] !== null ? scrapers.push( new Fantacalcio(sources[0]) ) :null;
	sources[1] !== null ? scrapers.push( new SosFanta(sources[1]) ) :null;
	sources[2] !== null ? scrapers.push( new Gazzetta(sources[2]) ) :null;
	sources[3] !== null ? scrapers.push( new SkySport(sources[3]) ) :null;
	

	for(let scraper of scrapers)
		await scraper.scrape();

	for(let player of await PlayerDataModel.find({}).populate("team") ){
		let playerStarting: Array<[string,boolean]> = []

		for(let scraper of scrapers){
			let playerIdsInTeam: Array<string> = scraper._result.get(
				((player as any).team.name)
				);

			playerStarting.push([
				scraper.source.abbreviation,					
				playerIdsInTeam.map(id=>{
					return id.toString();
					}).includes(player.player.toString())
			]);
		}

		await PlayerDataModel.findByIdAndUpdate((player as any)._id, {
			starting:playerStarting
		});
	}

	mongoose.connection.close();
}


mongoose.connect(
	getMongoUrl()+'/titolari',{
		useUnifiedTopology: true,
		useNewUrlParser: true,
		useFindAndModify:false
	});
run();