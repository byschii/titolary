
/**
 * in questo file ci sono le funzioni che 
 * servono a prendere dati sulle squadre
 * 
 * definiamoli 'DATI LENTI' quinid anche se non
 * ho architetturato troppo bene i dati me la posso cavare
 */


import { TeamData, TeamDataModel } from '../bricks/team_data';
import { getPageHtml } from '../../../utils/utils';
import { TeamEnum, TeamEnumModel } from '../bricks/team_enum';

const JSSoup = require('jssoup').default;


/**
 * pulisce la tabella tutte le volte che la volio rifare
 */
export async function cleanTeamData(){
    await TeamDataModel.deleteMany({});
}

async function getTeamDataInfo(): Promise<Array<[string,string]>>{
    
    let info : Array<[string,string]> = [];
    
    let soup = new JSSoup( await getPageHtml('http://www.legaseriea.it/it/serie-a/classifica'));
    let leaderBoard = soup.find("table", {class:"classifica"}).find("tbody");
    for(let row of leaderBoard.findAll("tr")){
        let logoUrl = 'http://www.legaseriea.it/' + (row.find("img").attrs.src as string);
        let teamName = row.find("img").attrs.title;
        
        info.push([logoUrl, teamName]);
    }

    return info;
}

/**
 * questa funzione è quella che salva effettivamente
 * salva alcuni dati sulla squadra
 */
export async function saveTeamData(){
    for(let info of await getTeamDataInfo()){
        let te : TeamEnum|null = await TeamEnumModel.findOne({name: info[1]});
        if(te !== null){
            let tdm = new TeamData(te, info[0]);
            await TeamDataModel.create(tdm);

        }else{
            throw "team not found!";
        }
    
    }
}