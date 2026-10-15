"""Normalize downloaded primary-source snapshots; no network calls or third-party packages.

Run from the app root: python3 Core/normalize.py
"""
from pathlib import Path
import html
import json
import re

root = Path(__file__).resolve().parent
table = json.loads((root / "SourceData/pubchem-periodic-table.json").read_text())["Table"]
columns = table["Columns"]["Column"]
raw = html.unescape((root / "SourceData/nist-isotopes-source.txt").read_text())
isotopes = {}
compositions = {}
for block in raw.split("\n\n"):
    values = dict(re.findall(r"^(Atomic Number|Mass Number|Isotopic Composition) = (.*)$", block, re.M))
    if "Atomic Number" not in values:
        continue
    z, mass = int(values["Atomic Number"]), int(values["Mass Number"])
    isotopes.setdefault(z, []).append(mass)
    match = re.match(r"[\d.]+", values["Isotopic Composition"])
    if match:
        compositions.setdefault(z, []).append((float(match.group()), mass))

# IUPAC 4 May 2022 chart: mass numbers printed in square brackets, not rounded
# weighted atomic masses. These are representative radioactive isotopes.
iupac_representatives = {
    43:97, 61:145, 84:209, 85:210, 86:222, 87:223, 88:226, 89:227,
    93:237, 94:244, 95:243, 96:247, 97:247, 98:251, 99:252,
    100:257, 101:258, 102:259, 103:262, 104:267, 105:268,
    106:269, 107:270, 108:269, 109:277, 110:281, 111:282,
    112:285, 113:286, 114:290, 115:290, 116:293, 117:294, 118:294
}

def number(value):
    try:
        return float(value)
    except (TypeError, ValueError):
        return None

def position(z):
    if z <= 2: return (1, 1 if z == 1 else 18)
    if z <= 10: return (2, z - 2 if z <= 4 else z + 8)
    if z <= 18: return (3, z - 10 if z <= 12 else z)
    if z <= 36: return (4, z - 18)
    if z <= 54: return (5, z - 36)
    if z <= 86:
        return (6, z - 54 if z <= 56 else (0 if z <= 71 else z - 68))
    return (7, z - 86 if z <= 88 else (0 if z <= 103 else z - 100))

elements = []
for row in table["Row"]:
    assert len(row["Cell"]) == len(columns)
    source = dict(zip(columns, row["Cell"]))
    z = int(source["AtomicNumber"])
    period, group = position(z)
    mass = iupac_representatives.get(z)
    if mass is None:
        mass = max(compositions[z])[1]
    # Do not invent an isotope if a newer IUPAC mass is absent from old NIST.
    # Its explicitly sourced IUPAC record is added to the documented list.
    if mass not in isotopes[z]:
        assert z in iupac_representatives
        isotopes[z].append(mass)
    configuration = source["ElectronConfiguration"]
    if z == 103:
        configuration = "[Rn]5f14 7s2 7p1"  # Current NIST Elemental Data Index.
    elements.append({
        "atomicNumber": z, "symbol": source["Symbol"], "name": source["Name"],
        "atomicMass": number(source["AtomicMass"]), "category": source["GroupBlock"],
        "period": period, "group": group, "electronConfiguration": configuration,
        "electronegativity": number(source["Electronegativity"]),
        "atomicRadius": number(source["AtomicRadius"]),
        "ionizationEnergy": number(source["IonizationEnergy"]),
        "meltingPoint": number(source["MeltingPoint"]),
        "boilingPoint": number(source["BoilingPoint"]), "density": number(source["Density"]),
        "standardState": source["StandardState"],
        "representativeIsotopeMassNumber": mass,
        "configurationIsPredicted": "predicted" in configuration or "calculated" in configuration,
    })
assert len(elements) == 118
(root / "Resources/elements.json").write_text(json.dumps(elements, indent=2) + "\n")
(root / "Resources/isotopes.json").write_text(json.dumps({str(z): sorted(set(masses)) for z, masses in isotopes.items()}, separators=(",", ":")) + "\n")
print(f"Normalized {len(elements)} elements and {sum(len(v) for v in isotopes.values())} isotope records.")
