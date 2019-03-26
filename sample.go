package main

import (
	"bytes"
	"encoding/base64"
	"io/ioutil"
	"log"
	"os"
	"fmt"
	"golang.org/x/crypto/openpgp"
)

// create gpg keys with
// $ gpg --gen-key
// ensure you correct paths and passphrase

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

func main() {
	//encryption started
	//read from plain file
	plainSrc, err := os.Open("/Users/szhang/go/src/codec/plain.txt")
	if err != nil{
	  log.Fatal(err)
	}
	defer plainSrc.Close()
 
	buf1 := new(bytes.Buffer)
	buf1.ReadFrom(plainSrc)
	contents1 := buf1.String()
	
	//encrytpion
	encStr, err := encTest(contents1)
	if err != nil {
		log.Fatal(err)
	}

	//output encrypted file 
    f1, err := os.Create("/Users/szhang/go/src/codec/encrypted.txt.gpg")
    if err != nil {
        log.Fatal(err)
	}
	
	l1, err := f1.WriteString(encStr)	
    if err != nil {
		f1.Close()
		log.Fatal(err)
    }
	fmt.Println(l1, "encryption written successfully")		

	//decryption started

	//read encrypted file
	filerc, err := os.Open("/Users/szhang/go/src/codec/encrypted.txt.gpg")
	if err != nil{
	  log.Fatal(err)
	}
	defer filerc.Close()
 
	buf2 := new(bytes.Buffer)
	buf2.ReadFrom(filerc)
	contents2 := buf2.String() 

	//dycryption
	decStr, err := decTest(contents2)
	if err != nil {
		log.Fatal(err)
	}

	//output dycrypted file
    f2, err := os.Create("/Users/szhang/go/src/codec/decrypted.txt")
    if err != nil {
        log.Fatal(err)
	}	
	f2.WriteString(decStr)	

	log.Println("Decrypted Secret:", decStr)
}
