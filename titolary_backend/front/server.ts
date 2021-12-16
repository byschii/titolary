import express from 'express';
import {router} from "./routers";
import { mongoose } from '@typegoose/typegoose';
import { getMongoUrl, getConfiguration } from '../utils/utils';
import { FirebaseController } from './firebase_controller';


FirebaseController.initFirebaseApp();

mongoose.connect( getMongoUrl()+'/titolari', {
	useUnifiedTopology: true,
	useNewUrlParser: true,
	useFindAndModify:false
});




// Create a new express application instance
const app: express.Application = express();


app.locals.CHECK_LOGIN = false;


app.use(express.urlencoded({extended:false}));
app.use((req: express.Request, res: express.Response, next: express.NextFunction)=>{
    res.locals.responde = function(statusParam:number, messageParam: string, dataParam:any ){
		return res.json({
			data: dataParam,
			message: messageParam,
			status: statusParam
		});
	} 
    next();
});

// ho messo anche la v1, insieme così sull app
// non si accorgeranno di nulla
app.use('/',router);
app.use('/v1',router);


app.listen(getConfiguration().ports.titolari, ()=>{
	console.log("running on > " + getConfiguration().ports.titolari);
});