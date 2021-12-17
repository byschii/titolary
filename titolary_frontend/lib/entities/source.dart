class Source{
  String _name;
  String _lineupsUrl;
  String _shortName;

  String get name => this._name;
  String get shortName => this._shortName;

  Source._(String name, String lineupsUrl, String shortName ){
    this._name = name;
    this._lineupsUrl = lineupsUrl;
    this._shortName = shortName;
  }

  static Source fromString(String initString){
    switch (initString) {
      case "SOSF": return new Source._("SosFanta", "", initString);
      case "FANT": return new Source._("Fantacalcio", "", initString);
      //case "FANT": return new Source._("Fantagazzetta", "", initString);
      case "SKYS": return new Source._("Sky Sport", "", initString);
      case "GAZZ": return new Source._("Gazzetta", "", initString);
      //case "GAZZ": return new Source._("Gazzetta dello Sport", "", initString);

      default:
        throw "Init string not recognized";
    }

  }
}