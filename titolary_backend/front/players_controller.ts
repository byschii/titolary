import express from 'express';
import {ObjectId} from 'mongodb';
import { PlayerDataModel, PlayerData } from "../entities/foundations/bricks/player_data";
import { fuzzySearchInArray } from '../utils/utils';

export class PlayersController {
    static async getPlayer(req: express.Request, res: express.Response, next: express.NextFunction){
        let player_hint: string = req.query.phint;
        let many : number = req.query.many;

        if(!player_hint || !many){
            return res.locals.responde(400, "some query field is missing", null);
        }

        try{
            let playerList = await PlayerDataModel.find({}).populate("player").populate("team");
            let players : PlayerData[] = fuzzySearchInArray(playerList, ["player.name"], player_hint, Math.floor(many/0.51));

            return res.locals.responde(200, "here's your data", players);
        }catch(err){
            if(err instanceof Error){
                return res.locals.responde(500, "unknown error on server accured", err.stack);
            }else{
                return res.locals.responde(500, "unknown error on server accured", null);
            }        
        }
    }

    static async getTeam(req: express.Request, res: express.Response, next: express.NextFunction){
        let team_hint: string = req.query.thint;
        let many : number = req.query.many;

        if(!team_hint || !many){
            return res.locals.responde(400, "some query field is missing", null);
        }

        try{
            let playerList = await PlayerDataModel.find({}).populate("player").populate("team");
            let team : PlayerData[] = fuzzySearchInArray(playerList, ["team.name"], team_hint, 40);

            let teamPrecise = team.filter( (p:PlayerData)=>{
                return p.team == team[0].team;
            });

            let teamFiltered = teamPrecise.sort((p1:PlayerData, p2: PlayerData) =>{
                let tit1: number = p1.starting.map( (val: [string, boolean]) : number => {
                    return val[1] ? 1 : 0;
                }).reduce( (v1:number, v2:number)=>{return v1+v2} );

                let tit2: number = p2.starting.map( (val: [string, boolean]) : number => {
                    return val[1] ? 1 : 0;
                }).reduce( (v1:number, v2:number)=>{return v1+v2} );

                return tit1 - tit2;
            }).reverse();

            return res.locals.responde(200, "here's your data", teamFiltered);
        }catch(err){
            if(err instanceof Error){
                return res.locals.responde(500, "unknown error on server accured", err.stack);
            }else{
                return res.locals.responde(500, "unknown error on server accured", null);
            } 
        }
        
    }
 
    static async getPrefered(req: express.Request, res: express.Response, next: express.NextFunction){
        let prefered: object = req.query.prefs === undefined ? {} : req.query.prefs ;
        let ids: Array<ObjectId> = [];

        for(let idString of Object.values(prefered)  ){
            ids.push( new ObjectId(idString));
        }
        
        if(!prefered || !ids){
            return res.locals.responde(400, "some query field is missing", null);
        }
        

        try{
            let playerList = await PlayerDataModel.find({
                _id:{ $in:ids}
            }).populate("player").populate("team");

            let playerListFiltered = playerList.filter((doc)=>{
                return doc !== null;
            });

            if(playerListFiltered.length > 35){
                return res.locals.responde(400, "you are a bad guy", null);
            }

            return res.locals.responde(200, "Here's your data", playerListFiltered ); 
        }catch(err){
            if(err instanceof Error){
                return res.locals.responde(500, "unknown error on server accured", err.stack);
            }else{
                return res.locals.responde(500, "unknown error on server accured", null);
            }             
        }        
    }
}
