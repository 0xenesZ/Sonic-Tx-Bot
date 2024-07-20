#!/bin/bash

BOLD_BLUE='\033[1;34m'
NC='\033[0m'
echo
if ! command -v node &> /dev/null; then
    echo -e "${BOLD_BLUE}Node.js is not installed. Installing Node.js...${NC}"
    echo
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo -e "${BOLD_BLUE}Node.js is already installed.${NC}"
fi
echo
if ! command -v npm &> /dev/null; then
    echo -e "${BOLD_BLUE}npm is not installed. Installing npm...${NC}"
    echo
    sudo apt-get install -y npm
else
    echo -e "${BOLD_BLUE}npm is already installed.${NC}"
fi
echo
echo -e "${BOLD_BLUE}Creating project directory and navigating into it${NC}"
mkdir -p SonicBatchTx
cd SonicBatchTx || exit
echo
echo -e "${BOLD_BLUE}Initializing a new Node.js project${NC}"
echo
npm init -y
echo
echo -e "${BOLD_BLUE}Installing required packages${NC}"
echo
npm install @solana/web3.js chalk bs58
echo
echo -e "${BOLD_BLUE}Prompting for private key${NC}"
echo
read -p "Enter your solana wallet private key: " privkey
echo
echo -e "${BOLD_BLUE}Creating the Node.js script file${NC}"
echo
cat << EOF > zun.mjs
import { Connection, Keypair, Transaction, SystemProgram, LAMPORTS_PER_SOL, sendAndConfirmTransaction } from "@solana/web3.js";
import chalk from "chalk";
import bs58 from "bs58";

const connection = new Connection("https://api.devnet.solana.com", 'confirmed');

const privkey = "$privkey";
const from = Keypair.fromSecretKey(bs58.decode(privkey));

(async () => {
    try {
        for (let i = 0; i < 100; i++) {
            const to = Keypair.generate();
            const transaction = new Transaction().add(
                SystemProgram.transfer({
                    fromPubkey: from.publicKey,
                    toPubkey: to.publicKey,
                    lamports: LAMPORTS_PER_SOL * 0.001,
                })
            );

            const signature = await sendAndConfirmTransaction(connection, transaction, [from]);
            console.log(chalk.blue('Tx hash :'), signature);

            const randomDelay = Math.floor(Math.random() * 3) + 1;
            await new Promise(resolve => setTimeout(resolve, randomDelay * 1000));
        }
    } catch (error) {
        console.error(chalk.red('Error during transaction:'), error);
    }
})();
EOF
echo
echo -e "${BOLD_BLUE}Executing the Node.js script${NC}"
echo
node zun.mjs
echo
