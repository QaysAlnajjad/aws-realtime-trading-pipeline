#!/usr/bin/env python3
import json
import sys
from datetime import datetime

def parse_trading_data(filename):
    with open(filename, 'r') as f:
        content = f.read().strip()
    
    # Split by }{ pattern and fix JSON format
    records = []
    parts = content.split('}{')
    
    for i, part in enumerate(parts):
        if i == 0:
            part += '}'
        elif i == len(parts) - 1:
            part = '{' + part
        else:
            part = '{' + part + '}'
        
        try:
            record = json.loads(part)
            records.append(record)
        except json.JSONDecodeError:
            continue
    
    return records

def analyze_data(records):
    symbols = {}
    
    for record in records:
        symbol = record['symbol']
        price = record['price']
        volume = record['volume']
        
        if symbol not in symbols:
            symbols[symbol] = {'prices': [], 'volumes': [], 'count': 0}
        
        symbols[symbol]['prices'].append(price)
        symbols[symbol]['volumes'].append(volume)
        symbols[symbol]['count'] += 1
    
    print(f"Total records: {len(records)}")
    print("\nSymbol Analysis:")
    print("-" * 60)
    
    for symbol, data in symbols.items():
        avg_price = sum(data['prices']) / len(data['prices'])
        min_price = min(data['prices'])
        max_price = max(data['prices'])
        total_volume = sum(data['volumes'])
        
        print(f"{symbol:5} | Records: {data['count']:3} | Avg: ${avg_price:7.2f} | "
              f"Range: ${min_price:7.2f}-${max_price:7.2f} | Volume: {total_volume:,}")

if __name__ == "__main__":
    filename = sys.argv[1] if len(sys.argv) > 1 else "trading-firehose-1-2025-10-22-12-58-35-2fee085f-0375-454e-8045-05e212d2dc35"
    
    try:
        records = parse_trading_data(filename)
        analyze_data(records)
    except FileNotFoundError:
        print(f"File {filename} not found")
    except Exception as e:
        print(f"Error: {e}")