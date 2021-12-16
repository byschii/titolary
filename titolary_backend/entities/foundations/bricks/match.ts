import { prop, index, staticMethod, Ref, getModelForClass, mongoose } from '@typegoose/typegoose';

import {TeamEnum, TeamEnumModel} from "./team_enum";

/**
 * questa classe serve ad abbinare due squadre ad una data,
 * con una lista di questi oggetti posso creare sostanzialmente 
 * una giornata di campionato
 */
export class Match {
    @prop({ref: TeamEnum})
    public home: Ref<TeamEnum>;

    @prop({ref: TeamEnum})
    public away: Ref<TeamEnum>;

    @prop()
    public date: Date;

    constructor(home: TeamEnum|Ref<TeamEnum>, away: TeamEnum|Ref<TeamEnum>, date:Date){
        this.home = home;
        this.away = away;
        this.date = date;
    }
    
}

export let MatchModel = getModelForClass(Match);