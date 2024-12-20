
const hre = require("hardhat");

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  const bdolaToken = await hre.ethers.deployContract("BDOLAToken");
  await bdolaToken.waitForDeployment();
  console.log("BDOLAToken Contract Deployed at : ", bdolaToken.target);
  
  const dolaToken = await hre.ethers.deployContract("DolaToken",["0x14866185B1962B63C3Ea9E03Bc1da838bab34C19",bdolaToken.target]);
  await dolaToken.waitForDeployment();
  console.log("DolaToken Contract Deployed at : ", dolaToken.target);

  await sleep(30*1000);

  await hre.run("verify:verify",{
    address : bdolaToken.target,
    constructorArguments : []
  })

  await hre.run("verify:verify",{
    address : dolaToken.target,
    constructorArguments : ["0x14866185B1962B63C3Ea9E03Bc1da838bab34C19",bdolaToken.target]
  })
  
}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
