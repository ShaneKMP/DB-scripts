package main

import (
	"bytes"
	"encoding/base64"
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"golang.org/x/crypto/openpgp"
)

const prefix, passphrase = "/Users/szhang/go/src/codec/", "123"
const secretKeyring = prefix + "private.asc"
const publicKeyring = prefix + "public.asc"

func encTest(secretString string) (string, error) {
	log.Println("Secret to hide:", secretString)
	log.Println("Public Keyring:", publicKeyring)

	// Read in public key
	keyringFileBuffer, _ := os.Open(publicKeyring)
	defer keyringFileBuffer.Close()
	entityList, err := openpgp.ReadArmoredKeyRing(keyringFileBuffer)
	if err != nil {
		return "", err
	}

	// encrypt string
	buf := new(bytes.Buffer)
	w, err := openpgp.Encrypt(buf, entityList, nil, nil, nil)
	if err != nil {
		return "", err
	}
	_, err = w.Write([]byte(secretString))
	if err != nil {
		return "", err
	}
	err = w.Close()
	if err != nil {
		return "", err
	}

	// Encode to base64
	bytes, err := ioutil.ReadAll(buf)
	if err != nil {
		return "", err
	}
	encStr := base64.StdEncoding.EncodeToString(bytes)

	// Output encrypted/encoded string
	log.Println("Encrypted Secret:", encStr)

	return encStr, nil
}

func decTest(encString string) (string, error) {

	log.Println("Secret Keyring:", secretKeyring)
	log.Println("Passphrase:", passphrase)

	// init some vars
	var entity *openpgp.Entity
	var entityList openpgp.EntityList

	// Open the private key file
	keyringFileBuffer, err := os.Open(secretKeyring)
	if err != nil {
		return "", err
	}
	defer keyringFileBuffer.Close()
	entityList, err = openpgp.ReadArmoredKeyRing(keyringFileBuffer)
	if err != nil {
		return "", err
	}
	entity = entityList[0]

	// Get the passphrase and read the private key.
	// Have not touched the encrypted string yet
	passphraseByte := []byte(passphrase)
	log.Println("Decrypting private key using passphrase")
	entity.PrivateKey.Decrypt(passphraseByte)
	for _, subkey := range entity.Subkeys {
		subkey.PrivateKey.Decrypt(passphraseByte)
	}
	log.Println("Finished decrypting private key using passphrase")

	// Decode the base64 string
	dec, err := base64.StdEncoding.DecodeString(encString)
	if err != nil {
		return "", err
	}

	// Decrypt it with the contents of the private key
	md, err := openpgp.ReadMessage(bytes.NewBuffer(dec), entityList, nil, nil)
	if err != nil {
		return "", err
	}
	bytes, err := ioutil.ReadAll(md.UnverifiedBody)
	if err != nil {
		return "", err
	}
	decStr := string(bytes)

	return decStr, nil
}

func readFileToString(filePath string) (string, error) {
	src, err := os.Open(filePath)
	if err != nil {
		log.Fatal(err)
	}
	defer src.Close()

	buf := new(bytes.Buffer)
	buf.ReadFrom(src)
	contents := buf.String()
	return contents, nil
}

func writeStringToFile(str string, filePath string) {
	f, err := os.Create(filePath)
	if err != nil {
		log.Fatal(err)
	}

	l, err := f.WriteString(str)
	if err != nil {
		f.Close()
		log.Fatal(err)
	}

	fmt.Println(l, "written successfully")
}

func main() {
	//encryption started
	//read from plain file
	plain, err := readFileToString("/Users/szhang/go/src/codec/plain.txt")
	if err != nil {
		log.Fatal(err)
	}

	//encrytpion
	encStr, err := encTest(plain)
	if err != nil {
		log.Fatal(err)
	}

	//output encrypted file
	writeStringToFile(encStr, "/Users/szhang/go/src/codec/encrypted.txt.gpg")

	//decryption started

	//read encrypted file
	encrypted, err := readFileToString("/Users/szhang/go/src/codec/encrypted.txt.gpg")

	//dycryption
	decStr, err := decTest(encrypted)
	if err != nil {
		log.Fatal(err)
	}

	//output dycrypted file
	writeStringToFile(decStr, "/Users/szhang/go/src/codec/decrypted.txt")

	log.Println("Decrypted Secret:", decStr)
}
