# Gera a lista de taunts do SKYNET Taunts a partir do items_game.txt do proprio TF2.
# Builds the SKYNET Taunts list from TF2's own items_game.txt.
# Uso / Usage:
#   python3 gerar_lista_taunts.py <servidor>/tf/scripts/items/items_game.txt <servidor>/tf/addons/sourcemod/configs/skynet_taunts.txt
# Depois / Then: sm_taunts_reload
import re, sys
texto = open(sys.argv[1], encoding="utf-8", errors="replace").read()
tok = re.compile(r'"((?:[^"\\]|\\.)*)"|([{}])|//[^\n]*')
pilha, chave = [[]], None
for m in tok.finditer(texto):
    if m.group(0).startswith("//"):
        continue
    if m.group(2) == "{":
        novo = []
        pilha[-1].append((chave, novo)); pilha.append(novo); chave = None
    elif m.group(2) == "}":
        pilha.pop()
    elif chave is None:
        chave = m.group(1)
    else:
        pilha[-1].append((chave, m.group(1))); chave = None
def pega(no, k):
    for kk, v in no:
        if kk == k:
            return v
    return None
CLASSES = {"scout": 1, "sniper": 2, "soldier": 3, "demoman": 4, "medic": 5, "heavy": 6, "pyro": 7, "spy": 8, "engineer": 9}
itens = pega(pega(pilha[0], "items_game"), "items")
lista = []
for idx, it in itens:
    if not isinstance(it, list) or not idx.isdigit():
        continue
    prefab = pega(it, "prefab") or ""
    if "taunt" not in prefab.split() and pega(it, "item_slot") != "taunt":
        continue
    nome = pega(it, "name") or idx
    nome = re.sub(r"^Taunt: ", "", nome)
    nome = re.sub(r" Taunt$", "", nome).replace('"', "'")
    usados = pega(it, "used_by_classes") or []
    mascara = 0
    for c, _ in usados:
        if c.lower() in CLASSES:
            mascara |= 1 << CLASSES[c.lower()]
    if mascara == 0:
        mascara = 1022
    lista.append((nome.lower(), int(idx), nome, mascara))
lista.sort()
if len(lista) < 50:
    sys.exit("ERRO: so %d taunts encontradas, o arquivo nao foi alterado" % len(lista))
with open(sys.argv[2], "w") as f:
    f.write('"SkynetTaunts"\n{\n')
    for _, idx, nome, mascara in lista:
        f.write('    "%d"\n    {\n        "name"       "%s"\n        "classes"    "%d"\n    }\n' % (idx, nome, mascara))
    f.write("}\n")
print("taunts na lista: %d (de todas as classes: %d)" % (len(lista), sum(1 for x in lista if x[3] == 1022)))
