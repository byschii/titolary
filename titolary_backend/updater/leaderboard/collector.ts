import { mongoose } from '@typegoose/typegoose';
import { getMongoUrl } from '../../utils/utils';
import {LeaderboardScraper} from './scraper';

async function run(){

    await LeaderboardScraper.getLeaderboad()

    

    mongoose.connection.close();
}


mongoose.connect(
	getMongoUrl()+'/titolari',{
		useUnifiedTopology: true,
		useNewUrlParser: true,
		useFindAndModify:false
	});
run();