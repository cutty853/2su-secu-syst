#!/bin/bash

# usage: fuzzer.sh <binary_path> <source_code_dir>
#
# binary_path: le chemin vers le binaire à patcher
# source_code_dir: le chemin vers le dossier contenant le main.c

BIN_PATH=$1
SOURCE_CODE_DIR=$2

recompile_binary() {
    rm -rf $BIN_PATH
    gcc -o $BIN_PATH $SOURCE_CODE_DIR/main.c
}

is_binary_patched() {
    validity_answer=$(echo "toto" | ./$BIN_PATH | cut -d' ' -f 5-)

    if [[ "$validity_answer" == "That's correct!" ]]; then
        echo "ok"
    else
        echo "ko"
    fi
}

offset_of_is_valid() {
    objdump -t out/emily | grep 'is_valid' | cut -d' ' -f 1
}

hex_to_decimal() {
    python -c "print(int('$1', 16))"
}

recompile_binary
seek_offset=$(hex_to_decimal $(offset_of_is_valid))
echo "base offset = $seek_offset (offset de la fonction 'is_valid')"
while [[ "$(is_binary_patched)" == "ko" ]]; do
    recompile_binary
    printf '\x01' | dd bs=1 count=1 of=$BIN_PATH conv=notrunc seek=$seek_offset status=none
    let seek_offset+=1
done

echo "--------"
echo "Le binaire à été patché avec succès ! offset=$seek_offset"
echo "En voici la preuve avec le mot de passe 'toto'."
echo "--------"
echo "toto" | ./$BIN_PATH
