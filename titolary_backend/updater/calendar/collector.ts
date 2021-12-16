import { CalendarScraper } from './scraper';
import { mongoose } from '@typegoose/typegoose';
import { getMongoUrl } from '../../utils/utils';
import { MatchModel } from '../../entities/foundations/bricks/match';

async function run(){
	
	let promises = await Promise.all([MatchModel.deleteMany({}), CalendarScraper.getCalendar()]);
	
	let toSave = promises[1].map( (match) => MatchModel.create(match) );
	await Promise.all(toSave);


	console.log(promises[1]);

    mongoose.connection.close();
}


async function run2(){
	
	let x = CalendarScraper.checkRightChampionshipDay( await CalendarScraper.getLastChampionshipDay());
	console.log(x);
    mongoose.connection.close();
}

mongoose.connect(
	getMongoUrl()+'/titolari',{
		useUnifiedTopology: true,
		useNewUrlParser: true,
		useFindAndModify:false
	});

run();