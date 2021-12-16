import fetch from 'node-fetch';

const cors = require('cors')({ origin: true });
const MongoClient = require('mongodb').MongoClient;
import Fuse from 'fuse.js';
import fs from 'fs';
import path from 'path';

import {ReturnModelType, Typegoose} from "@typegoose/typegoose";
import { FieldPath } from '@google-cloud/firestore';



export async function getPageHtml(url: string): Promise<string>{

	let page = await fetch(url, {
		method: 'get',
		/*headers:{
			'User-Agent':'titolary https://play.google.com/store/apps/details?id=titolary.byschii.com.titolary'
		},*/
		follow: 10
	});
	let pageContent:string = await page.text();
	return pageContent;
}

export function levenshteinDistance (s:string, t:string): number {

    let m = [], i, j, min = Math.min;

    if (!(s && t)) return (t || s).length;

    for (i = 0; i <= t.length; m[i] = [i++]);
    for (j = 0; j <= s.length; m[0][j] = j++);

    for (i = 1; i <= t.length; i++) {
        for (j = 1; j <= s.length; j++) {
            m[i][j] = t.charAt(i - 1) == s.charAt(j - 1)
                ? m[i - 1][j - 1]
                : m[i][j] = min(
                    m[i - 1][j - 1] + 1, 
                    min(m[i][j - 1] + 1, m[i - 1 ][j] + 1))
        }
    }

    return m[t.length][s.length];
}

export function longestCommonSubsequence(a:string, b:string) : string{
	var aSub = a.substr(0, a.length - 1);
	var bSub = b.substr(0, b.length - 1);
	if (a.length === 0 || b.length === 0) {
		return '';
	} else if (a.charAt(a.length - 1) === b.charAt(b.length - 1)) {
		return longestCommonSubsequence(aSub, bSub) + a.charAt(a.length - 1);
	} else {
		var x = longestCommonSubsequence(a, bSub);
		var y = longestCommonSubsequence(aSub, b);
		return (x.length > y.length) ? x : y;
	}
}

export function simpleLongestCommonSubsequence(a:string, b:string) : number{
	return longestCommonSubsequence(a, b).length;
}

export async function fuzzySearchInCollection(
	model:any,
	fieldsToPopulate: string[],
	keyFields: string[],
	searchWord: string,
	resultLen: number
	) : Promise<any[]> {

	let query = model.find({});
	if (fieldsToPopulate !== undefined){
		for(let field of fieldsToPopulate)
			query.populate(field);
	}

	let documentList = await query;
	let result = new Fuse(
		documentList, {
			keys: keyFields,
			tokenize:true
		}
	).search(searchWord);

	return result.slice(0,resultLen) as any[];
}

export function fuzzySearchInArray(
	itemList:any[],
	keyFields: string[],
	searchWord: string,
	resultLen:number
	) {

	let result = new Fuse(
		itemList, {
			keys: keyFields,
			tokenize:true
		}
	).search(searchWord);

	return result.slice(0,resultLen);
}

export function getConfiguration(){
	let configurationName = "../conf.json";
	let actualPosition = path.relative(__dirname,configurationName);

	let file: string = fs.readFileSync(path.join(__dirname,actualPosition), {
		encoding: 'utf-8'
	});
	
	return JSON.parse(file);
}

export function getFirebaseAccount(){
	let fileName = "./titolary-manz-firebase-adminsdk-manz-manz.json";
	let actualPosition = path.relative(__dirname,fileName)

	return require(path.join(__dirname,actualPosition));
}


export function getMongoUrl(){
	let url : string = "";
	url += "mongodb://";
	url += getConfiguration().domains.mongodb
	url += ":";
	url += getConfiguration().ports.mongodb

	return url;
}
