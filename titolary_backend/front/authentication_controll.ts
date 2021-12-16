export class AuthenticationControll{
    private _uptime: string | null = null;
    private _shouldRespond: boolean = false;
    private _authMessage: string = "Sorry, not allowed to get a response";
    
    constructor(shouldRespond:boolean, authMessage:string, uptime?:string){
        this._shouldRespond = shouldRespond;
        this._authMessage = authMessage;
        if(uptime !== undefined) this._uptime = uptime;
    }

    get uptime(): string | null{
        return this._uptime;
    }
    get shouldRespond(): boolean {
        return this._shouldRespond;
    }
    get authMessage(): string {
        return this._authMessage;
    }

}