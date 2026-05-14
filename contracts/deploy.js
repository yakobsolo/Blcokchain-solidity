const ethers = require("ethers");
const fs = require('fs-extra');

require('dotenv').config();

async function main() {
    
    const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

    const abi = fs.readFileSync("./SimpleStorage_sol_SimpleStorage.abi", "utf-8");
    const binary = fs.readFileSync("./SimpleStorage_sol_SimpleStorage.bin", "utf-8");

    const contractFactory = new ethers.ContractFactory(JSON.parse(abi), binary, wallet);

    console.log("Deploying, please wait...");

    // Specify gas limit (e.g., 3000000)
    const gasLimit = 3000000;

    const contract = await contractFactory.deploy({ gasLimit });
    await contract.waitForDeployment(1);
    console.log(`contract address: ${contract.address}`);
    const favaoritenumber = await contract.retrieve();
    console.log(`curent favo: ${favaoritenumber}`);
    const resp = await contract.store("1");
    await resp.waitForDeployment(0.1);
    const updatedfavnumb = await contract.retrieve();

    console.log(`after: ${updatedfavnumb}`);



    }

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
