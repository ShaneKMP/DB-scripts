package main

import (
	"bytes"
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"golang.org/x/crypto/openpgp"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"	
)

const passphrase = ""

type MyResponse struct {
	Message string `default response`
}

var svc = s3.New(session.New())

func encTest(secretString []byte) ([]byte, error) {
	//log.Println("Secret to hide:", secretString)
	//log.Println("Public Keyring:", publicKeyring)

	// Read in public key
	
	var key = os.Getenv("inputPathKey")
	var name = os.Getenv("inputPathBucket")

	obj, err := svc.GetObject(&s3.GetObjectInput{
		Bucket: aws.String(name),
		Key:    aws.String(key),
	})		

	body, err := ioutil.ReadAll(obj.Body)

	entityList, err := openpgp.ReadArmoredKeyRing(bytes.NewReader(body))
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
	var secretKeyring = "s3://aspiration-encrypt-decrypt/decryption/private.asc"
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

func HandleLambdaEvent(ctx context.Context, event events.S3Event) (MyResponse, error) {

	var operation = os.Getenv("operation")

    for _, rec := range event.Records {

        key := rec.S3.Object.Key

        // Download the file from S3
        obj, err := svc.GetObject(&s3.GetObjectInput{
            Bucket: aws.String(rec.S3.Bucket.Name),
            Key:    aws.String(key),
		})		
			
        // if err != nil {
        //     return fmt.Errorf("error in downloading %s from S3: %s\n", key, err)
        // }

        body, err := ioutil.ReadAll(obj.Body)
        // if err != nil {
        //     return fmt.Errorf("error in reading file %s: %s\n", key, err)
        // }		

		
		if operation == "enc" {
		
			encStr, err := encTest(body)
			if err != nil {
				log.Fatal(err)
			}
			
			//output encrypted file
			_, err = svc.PutObject(&s3.PutObjectInput{
				Bucket:               aws.String(os.Getenv("outputPathBucket")),
				Key:                  aws.String(os.Getenv("outputPathKey")),
				ACL:                  aws.String("private"),
				Body:                 bytes.NewReader(encStr),		
			})			
						
			log.Println("Encryption finished")
	
		} else {
			
			//dycryption
			//decStr, err := decTest(body)
			if err != nil {
				log.Fatal(err)
			}
	
			//output dycrypted file
			// writeBytesToFile(decStr, "s3://aspiration-encrypt-decrypt/encryption/decrypted_"+time.Now().Format("20060102150405")+".txt")
	
			log.Println("Decryption finished")
			
		}			
    }
    return MyResponse{Message: fmt.Sprintf("")}, nil	
}

func main() {

	svc = s3.New(session.Must(session.NewSession()))
	lambda.Start(HandleLambdaEvent)
}
