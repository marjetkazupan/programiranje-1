###############################################################################
# Hvaležni medved
#
# Pri tej nalogi bomo napisali nekaj funkcij, ki nam bodo v pomoč pri analizi
# literarnih besedil, kot je na primer koroška narodna pripovedka *Hvaležni
# medved*.
###############################################################################

test_text = """Gori nekje v gorah, ne ve se več, ali je bilo pri Macigoju ali
Naravniku, je šivala gospodinja v senci pod drevesom in zibala otroka. Naenkrat
prilomasti - pa prej ni ničesar opazila - medved in ji moli taco, v kateri je
tičal velik, debel trn. Žena se je prestrašila, a medved le milo in pohlevno
godrnja. Zato se žena ojunači in mu izdere trn iz tace. Mrcina kosmata pa zvrne
zibel, jo pobaše in oddide. Čez nekaj časa pa ji zopet prinese zibel, a zvhano
napolnjeno s sladkimi hruškami . Postavil jo je na tla pred začudeno mater in
odracal nazaj v goščavo. "Poglej no", se je razveselila mati, "kakšen hvaležen
medved. Zvrhano zibelko sladkih hrušk mi je prinesel za en sam izdrt trn"."""

###############################################################################
# 1) Sestavite funkcijo [find_words], ki vrne množico vseh besed, ki se
#    pojavijo v nizu in vsebujejo dan podniz.
#
# Namig: Pomagajte si z regex znakom za mejo [\b].
#
# >>> find_words(test_text, 'de')
# {'izdere', 'debel', 'oddide', 'začudeno'}
###############################################################################
import re

def find_words(text, podniz):
    regex = r"\b\w*" + podniz + r"\w*\b"
    # \b označi mejo med besedo in nebesedo - boljše od presledka, ker ujame tudi 
    # besede, na koncu katerih je pika
    #
    # z r označimo vrsto stringa, ki \ zazna kot \, ne kot ubežni znak; 
    # tu \n ni znak za novo vrstico, ampak je le \n
    # namesto r stringa bi lahko tudi pred vsakim \ pisali \ (torej \\ namesto \)
    # "\\b\\w*" + podniz + "\\w*\\b"
    return set(re.findall(regex, text))

print(find_words(test_text, 'de'))
###############################################################################
# 2) Sestavite funkcijo [find_prefix], ki vrne množico vseh besed, ki se
#    pojavijo v nizu in imajo dano predpono.
#
# >>> find_prefix(test_text, 'zi')
# {'zibala', 'zibel', 'zibelko'}
###############################################################################
def find_prefix(text, prefix):
    return set(re.findall(r"\b" + prefix + r"\w*\b", text))

print(find_prefix(test_text, 'zi'))
###############################################################################
# 3) Sestavite funkcijo [find_suffix], ki vrne množico vseh besed, ki se
#    pojavijo v nizu in imajo dano pripono.
#
# >>> find_suffix(test_text, 'la')
# {'zibala', 'razveselila', 'prestrašila', 'šivala', 'opazila', 'tla'}
###############################################################################
def find_suffix(text, suffix):
    return set(re.findall(r"\b\w*" + suffix + r"\b", text))

print(find_suffix(test_text, 'la'))
###############################################################################
# 4) Sestavite funkcijo [double_letters], ki sprejme niz in vrne množico vseh
#    besed, ki vsebujejo podvojene črke.
#
# >>> double_letters('A volunteer is worth twenty pressed men.')
# {'volunteer', 'pressed'}
###############################################################################
def double_letters(niz):
    return set(i for i, _ in re.findall(r"\b(\w*(\w)\2\w*)\b", niz))
    # Python vrne samo grupo v oklepaju (captured) - zato se eni oklepaji

print(double_letters('A volunteer is worth twenty pressed men.'))