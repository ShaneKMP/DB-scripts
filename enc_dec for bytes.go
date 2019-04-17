package main

import (
	"bytes"
	"flag"
	"io/ioutil"
	"log"
	"os"
	"strings"
	"time"

	"golang.org/x/crypto/openpgp"
)

const prefix, passphrase = "/Users/szhang/go/src/codec/", "123"
const secretKeyring = prefix + "private.asc"
const publicKeyring = prefix + "public.asc"

func encTest(secretString []byte) ([]byte, error) {
	//log.Println("Secret to hide:", secretString)
	//log.Println("Public Keyring:", publicKeyring)

	// Read in public key
	keyringFileBuffer, _ := os.Open(publicKeyring)
	defer keyringFileBuffer.Close()
	entityList, err := openpgp.ReadArmoredKeyRing(keyringFileBuffer)
	if err != nil {
		return nil, err
	}

	// encrypt string
	buf := new(bytes.Buffer)
	w, err := openpgp.Encrypt(buf, entityList, nil, nil, nil)
	if err != nil {
		return nil, err
	}
	_, err = w.Write([]byte(secretString))
	if err != nil {
		return nil, err
	}
	err = w.Close()
	if err != nil {
		return nil, err
	}

	// Encode to base64
	bytes, err := ioutil.ReadAll(buf)
	if err != nil {
		return nil, err
	}
	//encStr := base64.StdEncoding.EncodeToString(bytes)

	// Output encrypted/encoded string
	log.Println("Encrypted successfully")

	return bytes, nil
}

func decTest(encString []byte) ([]byte, error) {

	//log.Println("Secret Keyring:", secretKeyring)
	//log.Println("Passphrase:", passphrase)

	// init some vars
	var entity *openpgp.Entity
	var entityList openpgp.EntityList

	// Open the private key file
	keyringFileBuffer, err := os.Open(secretKeyring)
	if err != nil {
		return nil, err
	}
	defer keyringFileBuffer.Close()
	entityList, err = openpgp.ReadArmoredKeyRing(keyringFileBuffer)
	if err != nil {
		return nil, err
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
	// dec, err := base64.StdEncoding.DecodeString(encString)
	// if err != nil {
	// 	return nil, err
	// }

	// Decrypt it with the contents of the private key
	md, err := openpgp.ReadMessage(bytes.NewBuffer(encString), entityList, nil, nil)
	if err != nil {
		return nil, err
	}
	bytes, err := ioutil.ReadAll(md.UnverifiedBody)
	if err != nil {
		return nil, err
	}
	//decStr := string(bytes)

	return bytes, nil
}

func readFileToBytes(filePath string) ([]byte, error) {
	src, err := os.Open(filePath)
	if err != nil {
		log.Fatal(err)
	}
	defer src.Close()

	buf := new(bytes.Buffer)
	count, err := buf.ReadFrom(src)
	if err != nil {
		log.Fatal(err)
	}

	log.Println(count, "bytes has been read from file successfully")

	bytes, err := ioutil.ReadAll(buf)
	if err != nil {
		return nil, err
	}
	return bytes, nil
}

func writeBytesToFile(bytes []byte, filePath string) {
	err := ioutil.WriteFile(filePath, bytes, 0644)
	if err != nil {
		log.Fatal(err)
	}

	log.Println("bytes has been written to file successfully")
}

func main() {
	//encryption started
	//read from plain file
	var input string
	flag.StringVar(&input, "input", "", "enc/dec,filepath")
	flag.Parse()
	arr := strings.Split(input, ",")

	if arr[0] == "enc" {

		plain, err := readFileToBytes(arr[1])
		if err != nil {
			log.Fatal(err)
		}

		encStr, err := encTest(plain)
		if err != nil {
			log.Fatal(err)
		}

		//output encrypted file
		writeBytesToFile(encStr, "/Users/szhang/go/src/codec/encrypted_"+time.Now().Format("20060102150405")+".txt.gpg")

		log.Println("Encryption finished")

	} else {

		//read encrypted file
		encrypted, err := readFileToBytes(arr[1])
		//dycryption
		decStr, err := decTest(encrypted)
		if err != nil {
			log.Fatal(err)
		}

		//output dycrypted file
		writeBytesToFile(decStr, "/Users/szhang/go/src/codec/decrypted_"+time.Now().Format("20060102150405")+".txt")

		log.Println("Decryption finished")
	}
}
