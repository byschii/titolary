const JSSoup = require('jssoup').default;

import {Match, MatchModel} from "../../entities/foundations/bricks/match";
import { getPageHtml, fuzzySearchInCollection } from "../../utils/utils";
import { TeamEnum, TeamEnumModel } from '../../entities/foundations/bricks/team_enum';
import moment from 'moment';


export class CalendarScraper{
    private static LEGA_SERIE_A_CALENDAR_URL = "http://www.legaseriea.it/it/serie-a/calendario-e-risultati"
    
    public static async getLastChampionshipDay(): Promise<typeof JSSoup>{
        let pageHTML = await getPageHtml(this.LEGA_SERIE_A_CALENDAR_URL);
        return new JSSoup(pageHTML);
    }

    private static async getSpectificChampionshipDay(day: number): Promise<typeof JSSoup>{
        let pageHTML = await getPageHtml(
            this.LEGA_SERIE_A_CALENDAR_URL + '/2019-20/UNICO/UNI/' + day.toString());
        return new JSSoup(pageHTML);

    }

    public static checkRightChampionshipDay(page: typeof JSSoup): number {
        let calendarDay: string = page.find("section",{class:"risultati"}).find("h3").text;
        let data = calendarDay.trim().split(' ');
        
        let dateDisplyed = new Date(data[data.length -1]);
        
        if(moment(Date.now()).isBefore(dateDisplyed)) {
            return Number.parseInt(data[0].replace('^',''));
        }else{
            return Number.parseInt(data[0].replace('^','')) + 1;
        }
    }

    public static async getCalendar(): Promise<Array<Match>>{
        let proto_page : typeof JSSoup = await CalendarScraper.getLastChampionshipDay();
        let page: typeof JSSoup = await CalendarScraper.getSpectificChampionshipDay(CalendarScraper.checkRightChampionshipDay(proto_page));
        let championshipDay : Array<Match> = [];

        /*terconsole.log(
            page.findAll("div", {class:"box-partita"})
        );*/

        for(let match of page.findAll("div", {class:"box-partita"})){
            let datetime = match.findAll("span")[0];
            let teams : Array<string> = match.findAll('h4').map(
                (element:any) => element.text
            );

            let teamHome = await fuzzySearchInCollection(
				TeamEnumModel, [], ["name"], teams[0].substr(1), 1
			);

            let teamAway: any[] = await fuzzySearchInCollection(
                TeamEnumModel, [], ["name"], teams[1].substr(1), 1
            );

            let rawDateTime:string = datetime.text.trim();
            let dateTimeComponents = rawDateTime.split(' ');
            let dateComponents = dateTimeComponents[0].split('/');
            
            let sortedDateTime = [ dateComponents[2], dateComponents[1], dateComponents[0]].join('/') + " " + dateTimeComponents[1]; 
            let matchDate: Date = new Date( sortedDateTime );
            championshipDay.push(
                new Match(teamHome[0], teamAway[0], matchDate)
                );

        }
        return championshipDay;

    }

}