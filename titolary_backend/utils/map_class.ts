export class Map<V> {
    private items: { [key: string]: V };

    constructor() {
        this.items = {};
    }

    add(key: string, value: V): void {
        this.items[key] = value;
    }

    has(key: string): boolean {
        return key in this.items;
    }

    get(key: string): V {
        return this.items[key];
    }
}