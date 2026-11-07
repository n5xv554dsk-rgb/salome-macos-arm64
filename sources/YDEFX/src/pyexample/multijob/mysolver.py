#! /usr/bin/env python3
import argparse
if __name__ == '__main__':
  parser = argparse.ArgumentParser(description="Fake solver.")
  parser.add_argument("jdd", help="Input file.")
  parser.add_argument("resultat", help="Output file.")
  args = parser.parse_args()
  with open(args.jdd, 'r') as f:
    in_value = float(f.read())
  with open(args.resultat, 'w') as f:
    f.write(str(in_value * in_value))
