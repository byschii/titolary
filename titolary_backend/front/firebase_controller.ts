import firebaseAdmin from "firebase-admin";
import express from 'express';
import moment from "moment";

import { getFirebaseAccount } from "../utils/utils";
import { AuthenticationControll } from './authentication_controll';

export class FirebaseController{
    private static DEFINITION_OF_SHORT_TIME_IN_MINUTES : number = 5;
    private static DEFAULT_APP_NAME : string = "titolary_admin_node";

    public static initFirebaseApp(){
        if(firebaseAdmin.apps === null || firebaseAdmin.apps.length === 0){
            firebaseAdmin.initializeApp({
                credential: firebaseAdmin.credential.cert(getFirebaseAccount()),
                databaseURL: "https://titolary-manz.firebaseio.com"
            }, FirebaseController.DEFAULT_APP_NAME);
            console.log("firebase started");
        }else{
            console.log("firebase already started");
        }
    }

    public static destroyFirebaseApp(){
        if(firebaseAdmin.apps === null || firebaseAdmin.apps.length === 0){
            throw new Error("no firebase app to destroy");
        }else{
            firebaseAdmin.app(FirebaseController.DEFAULT_APP_NAME).delete();        
        }
    }

    public static getFirebaseApp(): firebaseAdmin.app.App {
        if(firebaseAdmin.apps === null || firebaseAdmin.apps.length === 0){
            throw new Error("no firebase app initialized");
        }else{
            return firebaseAdmin.app(FirebaseController.DEFAULT_APP_NAME);
        }
    }

    public static async getUserUptime(userId:string): Promise<string>{
        const firebaseDatabaseReference = FirebaseController.getFirebaseApp().database().ref();
        let snap = await firebaseDatabaseReference.child(`users/${userId}`).once("value");
        return Object.create(snap.val()).uptime;
    }

    private static isUserOnlineFromShortTime(uptime:string): boolean{
        let uptimeMoment = moment(uptime, 'YYYY-MM-DD HH:mm:ss.SSS' ).subtract(1, 'hour');
        let serverTime = moment( moment.now() ).utc();
        let serverUniversale = moment( serverTime.format('YYYY-MM-DD HH:mm:ss.SSS') );
        let tempo_passato : number = serverUniversale.diff( uptimeMoment , 'second' );
        return (tempo_passato/60) >= FirebaseController.DEFINITION_OF_SHORT_TIME_IN_MINUTES;
    }

    public static async authenticationMiddleware(req: express.Request, res: express.Response, next: express.NextFunction){
        let user_id : string = req.query.uid;
        
        if( !user_id ){
            res.locals.auth_controll = new AuthenticationControll(false, "User not defined");
        }else{
            let uptime : string = await FirebaseController.getUserUptime(user_id);
            if(uptime === undefined){
                res.locals.auth_controll = new AuthenticationControll(false, "User not online");
            }else if( FirebaseController.isUserOnlineFromShortTime(uptime) ){
                res.locals.auth_controll = new AuthenticationControll(false, "User should open-close");
            }else{
                res.locals.auth_controll = new AuthenticationControll(true, "Here's your data", uptime);
            }
        } 

        next();
    }

}