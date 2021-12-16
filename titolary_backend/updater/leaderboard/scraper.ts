const JSSoup = require('jssoup').default;

import { TeamEnumModel, TeamEnum } from '../../entities/foundations/bricks/team_enum';
import { getPageHtml } from '../../utils/utils';
import { TeamDataModel } from '../../entities/foundations/bricks/team_data';

export class LeaderboardScraper{

    public static async clean(): Promise<void>{
        //await TeamDataModel.find({});
    }

    private static async getLeaderboardHtml(): Promise<Array<[string,string]>>{
        let info : Array<[string,string]> = [];
    
        let soup = new JSSoup ( await getPageHtml('http://www.legaseriea.it/it/serie-a/classifica'));
        let leaderBoard = soup.find("table", {class:"classifica"}).find("tbody");
        for(let row of leaderBoard.findAll("tr")){
            let teamName = row.find("img").attrs.title;
            let pts = row.findAll("td")[1].text.trim();
            info.push([teamName, pts ]);
        }
    
        return info;
    }

    static async getLeaderboad(){
        for(let infos of await LeaderboardScraper.getLeaderboardHtml() ){
            let te : TeamEnum|null = await TeamEnumModel.findOne({name: infos[0]});
            if(te !== null){
                let tdm = await TeamDataModel.findOneAndUpdate({
                    team: te
                },{
                    leaderboardPoints:new Number(infos[1])
                },{
                    new: true
                }, (err)=>{
                    if(err)console.log(err);
                });
    
            }else{
                throw "team not found!";
            }
        }

    }


}