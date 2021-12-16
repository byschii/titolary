import express from 'express';
import {ObjectId} from 'mongodb';
import { fuzzySearchInArray } from '../utils/utils';
import { TeamDataModel, TeamData } from '../entities/foundations/bricks/team_data';
import { TeamEnum } from '../entities/foundations/bricks/team_enum';
import { MatchModel } from '../entities/foundations/bricks/match';

export class LeagueController {
    static async getCalendar(req: express.Request, res: express.Response, next: express.NextFunction){
        try{
            let calendar = await MatchModel.find({}).populate("home").populate("away");;
            return res.locals.responde(200, "here's your data", calendar);
        }catch(err){
            if(err instanceof Error){
                return res.locals.responde(500, "unknown error on server accured", err.stack);
            }else{
                return res.locals.responde(500, "unknown error on server accured", null);
            }        
        }
    }

    static async getLeaderboard(req: express.Request, res: express.Response, next: express.NextFunction){
        try{
            let leaderboard = await TeamDataModel.find({}).populate("team");
            let simplerLeaderboard = leaderboard.map(
                (td: TeamData)=> {
                    let simple : any = {
                        id: (td.team as any)._id,
                        name:  (td.team as TeamEnum).name,
                        points: td.leaderboardPoints,
                        logo: td.logoUrl
                    };
                    
                    return simple;
                });
            return res.locals.responde(200, "here's your data", simplerLeaderboard);
        }catch(err){
            if(err instanceof Error){
                return res.locals.responde(500, "unknown error on server accured", err.stack);
            }else{
                return res.locals.responde(500, "unknown error on server accured", null);
            }        
        }
    }

    static async getLeaderboardMatches(req: express.Request, res: express.Response, next: express.NextFunction){
        /**
         * una lista di oggetti tipo
         * {
         *  id squadra
         *  nome squadra
         *  logo squadra
         *  prox avversaria
         *  gioca in casa
         *  quando gioca
         * 
         * }
         */
        try{
            return res.locals.responde(200, "here's your data", "\{ id squadra, nome squadra, logo squadra, prox avversaria, gioca in casa, quando gioca \}");
        }catch(err){
            if(err instanceof Error){
                return res.locals.responde(500, "unknown error on server accured", err.stack);
            }else{
                return res.locals.responde(500, "unknown error on server accured", null);
            }        
        }
    }


}