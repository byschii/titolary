import express from 'express';
import { PlayersController } from './players_controller';
import { AuthenticationControll } from './authentication_controll';
import { FirebaseController } from './firebase_controller';
import { LeagueController } from './league_controller';
export const router = express.Router();


// controllo se dovrei rispondere
router.use(FirebaseController.authenticationMiddleware);
router.use((req: express.Request, res: express.Response, next: express.NextFunction)=>{
    let ac : AuthenticationControll = res.locals.auth_controll;  
    if( req.app.locals.CHECK_LOGIN && ac.shouldRespond === false ){
        let message: string = ac.authMessage + " > " + ac.uptime;
        return res.locals.responde(403, message, null);
    }else{
        next();
    }
});

// parte basata su i guicatori
router.get('/players_from_hint', PlayersController.getPlayer );
router.get('/teams_from_hint', PlayersController.getTeam);
router.get('/prefered', PlayersController.getPrefered);

//parte basata sulle squadre
router.get('/calendar', LeagueController.getCalendar);
router.get('/leaderboard', LeagueController.getLeaderboard);
