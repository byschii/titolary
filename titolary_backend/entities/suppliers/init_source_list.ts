const mongoose = require('mongoose');

import {Source, SourceModel} from './source';
import {getMongoUrl} from "../../utils/utils";

async function initSourceList(){
	let [s1,s2,s3]:Source[] = await Promise.all([
		SourceModel.create({
			name:"Fantacalcio",
			link:"https://www.fantacalcio.it",
			scrapeLink:"https://www.fantacalcio.it/probabili-formazioni-serie-a/",
			abbreviation:"FANT"
		}),
		SourceModel.create({
			name:"SOSFanta",
			link:"https://sosfanta.calciomercato.com/",
			scrapeLink:"https://sosfanta.calciomercato.com/probabili-formazioni/",
			abbreviation:"SOSF"
		}),
		SourceModel.create({
			name:"GazzettaDS",
			link:"https://www.gazzetta.it",
			scrapeLink:"https://www.gazzetta.it/Calcio/prob_form/",
			abbreviation:"GAZZ"
		}),
		SourceModel.create({
			name:"SkySport",
			link:"https://sport.sky.it",
			scrapeLink:"https://sport.sky.it/calcio/serie-a/probabili-formazioni",
			abbreviation:"SKYS"
		})
	])

	/*
		let switcher = [-1,-1,-1];
		for (var i = 0; i < Math.pow(2,3); i++) {
			for (var j = 0; j < 3; j++) {
				if(i % Math.pow(2,j) === 0)
					switcher[j]++;
			}

			for(let s of switcher){
				let res = s%2 == 0;
				await SourceOutcomeCombinationModel.create(
					new SourceOutcomeCombination(
						new SourceOutcome(s1,res),
						new SourceOutcome(s2,res),
						new SourceOutcome(s3,res)
					));
			}
				
		}
	*/

	mongoose.connection.close();
}

mongoose.connect(
	getMongoUrl()+'/titolari',{
		useUnifiedTopology: true,
		useNewUrlParser: true,
		useFindAndModify: false
	});
initSourceList();






