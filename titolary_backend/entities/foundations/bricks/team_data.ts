import {prop, index, staticMethod, Ref, getModelForClass } from '@typegoose/typegoose';
import { TeamEnum } from './team_enum';
import { levenshteinDistance } from '../../../utils/utils';

/**
 * questa classe serve solo a fare una grande lista di squadre
 * così ho dei riferimenti standard quando devo costruire i giocatori
 */
export class TeamData{
    @prop({ref: TeamEnum})
    public team: Ref<TeamEnum>;

    @prop()
    public logoUrl: string;

    @prop()
    public leaderboardPoints: number;

    constructor(
        team: TeamEnum|Ref<TeamEnum>,
        logoUrl: string){
        this.team = team;
        this.logoUrl = logoUrl;
        this.leaderboardPoints = 0;
        }

}

export const TeamDataModel = getModelForClass(TeamData);