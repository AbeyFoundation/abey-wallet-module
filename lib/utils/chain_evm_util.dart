import 'dart:math';
import 'dart:typed_data';
import 'package:abey_wallet/extension/string_extension.dart';
import 'package:abey_wallet/wallet/web3dart/contracts.dart';
import 'package:abey_wallet/wallet/web3dart/core/client.dart';
import 'package:abey_wallet/wallet/web3dart/core/ether_amount.dart';
import 'package:abey_wallet/wallet/web3dart/core/ether_unit.dart';
import 'package:abey_wallet/wallet/web3dart/core/transaction.dart';
import 'package:abey_wallet/wallet/web3dart/credentials/address.dart';
import 'package:abey_wallet/wallet/web3dart/credentials/credentials.dart';
import 'package:abey_wallet/utils/bip_util.dart' as bip39;
import 'package:abey_wallet/utils/bip32_util.dart' as bip32;
import 'package:abey_wallet/wallet/web3dart/crypto/formatting.dart';
import 'package:http/http.dart';

class ChainEvmClient {
  static Web3Client ConnectChain() {
    var httpClient = Client();
    var webClient = Web3Client("https://sepolia-rollup.arbitrum.io/rpc", httpClient);
    return webClient;
  }
}

class ChainEvmUtil {
  static int decimals = 18;
  static int chainId = 1;
  static final Web3Client client = ChainEvmClient.ConnectChain();

  //"0x9BF79A74704801E096224C75D1867831125C0A24"
  // static String actionEventAbiString = '[{"inputs": [],"stateMutability": "nonpayable","type": "constructor"},{"inputs": [{"internalType": "address","name": "sender","type": "address"},{"internalType": "uint256","name": "tokenId","type": "uint256"},{"internalType": "address","name": "owner","type": "address"}],"name": "ERC721IncorrectOwner","type": "error"},{"inputs": [{"internalType": "address","name": "operator","type": "address"},{"internalType": "uint256","name": "tokenId","type": "uint256"}],"name": "ERC721InsufficientApproval","type": "error"},{"inputs": [{"internalType": "address","name": "approver","type": "address"}],"name": "ERC721InvalidApprover","type": "error"},{"inputs": [{"internalType": "address","name": "operator","type": "address"}],"name": "ERC721InvalidOperator","type": "error"},{"inputs": [{"internalType": "address","name": "owner","type": "address"}],"name": "ERC721InvalidOwner","type": "error"},{"inputs": [{"internalType": "address","name": "receiver","type": "address"}],"name": "ERC721InvalidReceiver","type": "error"},{"inputs": [{"internalType": "address","name": "sender","type": "address"}],"name": "ERC721InvalidSender","type": "error"},{"inputs": [{"internalType": "uint256","name": "tokenId","type": "uint256"}],"name": "ERC721NonexistentToken","type": "error"},{"inputs": [{"internalType": "address","name": "owner","type": "address"}],"name": "OwnableInvalidOwner","type": "error"},{"inputs": [{"internalType": "address","name": "account","type": "address"}],"name": "OwnableUnauthorizedAccount","type": "error"},{"anonymous": false,"inputs": [{"indexed": true,"internalType": "address","name": "owner","type": "address"},{"indexed": true,"internalType": "address","name": "approved","type": "address"},{"indexed": true,"internalType": "uint256","name": "tokenId","type": "uint256"}],"name": "Approval","type": "event"},{"anonymous": false,"inputs": [{"indexed": true,"internalType": "address","name": "owner","type": "address"},{"indexed": true,"internalType": "address","name": "operator","type": "address"},{"indexed": false,"internalType": "bool","name": "approved","type": "bool"}],"name": "ApprovalForAll","type": "event"},{"anonymous": false,"inputs": [{"indexed": false,"internalType": "uint256","name": "_fromTokenId","type": "uint256"},{"indexed": false,"internalType": "uint256","name": "_toTokenId","type": "uint256"}],"name": "BatchMetadataUpdate","type": "event"},{"anonymous": false,"inputs": [{"indexed": false,"internalType": "uint256","name": "_tokenId","type": "uint256"}],"name": "MetadataUpdate","type": "event"},{"anonymous": false,"inputs": [{"indexed": true,"internalType": "address","name": "previousOwner","type": "address"},{"indexed": true,"internalType": "address","name": "newOwner","type": "address"}],"name": "OwnershipTransferred","type": "event"},{"anonymous": false,"inputs": [{"indexed": true,"internalType": "address","name": "from","type": "address"},{"indexed": true,"internalType": "address","name": "to","type": "address"},{"indexed": true,"internalType": "uint256","name": "tokenId","type": "uint256"}],"name": "Transfer","type": "event"},{"inputs": [],"name": "PRICE_PER_TOKEN","outputs": [{"internalType": "uint256","name": "","type": "uint256"}],"stateMutability": "view","type": "function"},{"inputs": [{"internalType": "address","name": "to","type": "address"},{"internalType": "uint256","name": "tokenId","type": "uint256"}],"name": "approve","outputs": [],"stateMutability": "nonpayable","type": "function"},{"inputs": [{"internalType": "address","name": "owner","type": "address"}],"name": "balanceOf","outputs": [{"internalType": "uint256","name": "","type": "uint256"}],"stateMutability": "view","type": "function"},{"inputs": [{"internalType": "uint256","name": "tokenId","type": "uint256"}],"name": "getApproved","outputs": [{"internalType": "address","name": "","type": "address"}],"stateMutability": "view","type": "function"},{"inputs": [{"internalType": "address","name": "owner","type": "address"},{"internalType": "address","name": "operator","type": "address"}],"name": "isApprovedForAll","outputs": [{"internalType": "bool","name": "","type": "bool"}],"stateMutability": "view","type": "function"},{"inputs": [{"internalType": "uint256","name": "tokenId","type": "uint256"},{"internalType": "string","name": "tokenURI","type": "string"}],"name": "mint","outputs": [],"stateMutability": "payable","type": "function"},{"inputs": [],"name": "name","outputs": [{"internalType": "string","name": "","type": "string"}],"stateMutability": "view","type": "function"},{"inputs": [],"name": "owner","outputs": [{"internalType": "address","name": "","type": "address"}],"stateMutability": "view","type": "function"},{"inputs": [{"internalType": "uint256","name": "tokenId","type": "uint256"}],"name": "ownerOf","outputs": [{"internalType": "address","name": "","type": "address"}],"stateMutability": "view","type": "function"},{"inputs": [],"name": "renounceOwnership","outputs": [],"stateMutability": "nonpayable","type": "function"},{"inputs": [{"internalType": "address","name": "from","type": "address"},{"internalType": "address","name": "to","type": "address"},{"internalType": "uint256","name": "tokenId","type": "uint256"}],"name": "safeTransferFrom","outputs": [],"stateMutability": "nonpayable","type": "function"},{"inputs": [{"internalType": "address","name": "from","type": "address"},{"internalType": "address","name": "to","type": "address"},{"internalType": "uint256","name": "tokenId","type": "uint256"},{"internalType": "bytes","name": "data","type": "bytes"}],"name": "safeTransferFrom","outputs": [],"stateMutability": "nonpayable","type": "function"},{"inputs": [{"internalType": "address","name": "operator","type": "address"},{"internalType": "bool","name": "approved","type": "bool"}],"name": "setApprovalForAll","outputs": [],"stateMutability": "nonpayable","type": "function"},{"inputs": [{"internalType": "bytes4","name": "interfaceId","type": "bytes4"}],"name": "supportsInterface","outputs": [{"internalType": "bool","name": "","type": "bool"}],"stateMutability": "view","type": "function"},{"inputs": [],"name": "symbol","outputs": [{"internalType": "string","name": "","type": "string"}],"stateMutability": "view","type": "function"},{"inputs": [{"internalType": "uint256","name": "tokenId","type": "uint256"}],"name": "tokenURI","outputs": [{"internalType": "string","name": "","type": "string"}],"stateMutability": "view","type": "function"},{"inputs": [{"internalType": "address","name": "from","type": "address"},{"internalType": "address","name": "to","type": "address"},{"internalType": "uint256","name": "tokenId","type": "uint256"}],"name": "transferFrom","outputs": [],"stateMutability": "nonpayable","type": "function"},{"inputs": [{"internalType": "address","name": "newOwner","type": "address"}],"name": "transferOwnership","outputs": [],"stateMutability": "nonpayable","type": "function"},{"inputs": [],"name": "withdraw","outputs": [],"stateMutability": "nonpayable","type": "function"}]';

  //"0x41ceaA1E107b728E38f8E5C53FA444a9b4eC77bF",
  static String actionEventAbiString = '[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"address","name":"owner","type":"address"}],"name":"ERC721IncorrectOwner","type":"error"},{"inputs":[{"internalType":"address","name":"operator","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"ERC721InsufficientApproval","type":"error"},{"inputs":[{"internalType":"address","name":"approver","type":"address"}],"name":"ERC721InvalidApprover","type":"error"},{"inputs":[{"internalType":"address","name":"operator","type":"address"}],"name":"ERC721InvalidOperator","type":"error"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"ERC721InvalidOwner","type":"error"},{"inputs":[{"internalType":"address","name":"receiver","type":"address"}],"name":"ERC721InvalidReceiver","type":"error"},{"inputs":[{"internalType":"address","name":"sender","type":"address"}],"name":"ERC721InvalidSender","type":"error"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"ERC721NonexistentToken","type":"error"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"OwnableInvalidOwner","type":"error"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"OwnableUnauthorizedAccount","type":"error"},{"inputs":[],"name":"ReentrancyGuardReentrantCall","type":"error"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"approved","type":"address"},{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"operator","type":"address"},{"indexed":false,"internalType":"bool","name":"approved","type":"bool"}],"name":"ApprovalForAll","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"_fromTokenId","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"_toTokenId","type":"uint256"}],"name":"BatchMetadataUpdate","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"_tokenId","type":"uint256"}],"name":"MetadataUpdate","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"minter","type":"address"},{"indexed":false,"internalType":"uint256","name":"tokenId","type":"uint256"},{"indexed":false,"internalType":"string","name":"tokenURI","type":"string"}],"name":"Minted","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"owner","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"Withdrawn","type":"event"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"approve","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"getApproved","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"operator","type":"address"}],"name":"isApprovedForAll","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"string","name":"tokenURI","type":"string"}],"name":"mint","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"mintPrice","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"ownerOf","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"safeTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"bytes","name":"data","type":"bytes"}],"name":"safeTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"operator","type":"address"},{"internalType":"bool","name":"approved","type":"bool"}],"name":"setApprovalForAll","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes4","name":"interfaceId","type":"bytes4"}],"name":"supportsInterface","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"tokenURI","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"transferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"withdraw","outputs":[],"stateMutability":"nonpayable","type":"function"}]';

  static final actionEventAbi = ContractAbi.fromJson(actionEventAbiString, 'ActionEvnet');

  static Future<String> getMnemonic() async {
    String mnemonic = bip39.generateMnemonic();
    return mnemonic;
  }

  static Future<String> getPrivateKey(mnemonic) async {
    try {
      final seed = bip39.mnemonicToSeed(mnemonic);
      final root = bip32.BIP32.fromSeed(seed);
      final drive = root.derivePath("m/44'/60'/0'/0/0");
      String privateKey = bytesToHex(drive.privateKey!.toList());
      return privateKey.startsWith("0x") ? privateKey : ("0x" + privateKey);
    } catch (e) {
      return "";
    }
  }

  static Future<String> getAddress(privateKey) async {
    try {
      Credentials credentials = EthPrivateKey.fromHex(privateKey);
      EthereumAddress address = await credentials.extractAddress();
      return address.hexEip55;
    } catch (e) {
      return "";
    }
  }

  static Future<bool> verityAddress(String address) async {
    try {
      EthereumAddress ethereumAddress = EthereumAddress.fromHex(address);
      if (ethereumAddress != null && ethereumAddress.hexEip55 != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<EtherAmount> getGasPrice() async {
    try {
      EtherAmount etherAmount = await client.getGasPrice();
      return etherAmount;
    } catch (e) {
      return EtherAmount.zero();
    }
  }

  static Future<EtherAmount> getBalance(String address) async {
    try {
      EthereumAddress ethereumAddress = EthereumAddress.fromHex(address);
      EtherAmount etherAmount = await client.getBalance(ethereumAddress);
      return etherAmount;
    } catch (e) {
      return EtherAmount.zero();
    }
  }

  static Future<int> getTransactionCount(String address) async {
    try {
      EthereumAddress ethereumAddress = EthereumAddress.fromHex(address);
      int nonce = await client.getTransactionCount(ethereumAddress);
      return nonce;
    } catch (e) {
      return -1;
    }
  }

  static Future<String> getGasFee(String from, String functionName, List<dynamic> parameters, dynamic contract, String contractAddress, {BigInt? value}) async {
    try {
      EthereumAddress fromAddress = EthereumAddress.fromHex(from);
      EthereumAddress toAddress = EthereumAddress.fromHex(contractAddress);
      EtherAmount gasPrice = await getGasPrice();
      Transaction transaction = Transaction.callContract(
          contract: contract,
          function: contract.function(functionName),
          parameters: parameters,
          gasPrice: gasPrice,
          from: fromAddress,
          value: value != null ? EtherAmount.fromBigInt(EtherUnit.wei, value) : EtherAmount.fromBase10String(EtherUnit.gwei, '0')
      );
      BigInt gasLimit;
      gasLimit = await client.estimateGas(
        sender: fromAddress,
        to: toAddress,
        data: transaction.data,
        value: transaction.value,
      );
      BigInt fee = gasLimit * gasPrice.getInWei;
      double result = fee / BigInt.from(pow(10, decimals));
      return result.toString();
    } catch (error) {
      return 'error' + error.toString();
    }
  }

  static Future<String> signTransaction(params, parameters) async {
    try {
      Credentials credentials = EthPrivateKey.fromHex(params["privateKey"]);
      String contract = params["contract"];
      Transaction transaction = Transaction();
      int nonce = await getTransactionCount(params["from"]);
      if (contract.isNotEmptyString()) {
        final DeployedContract deployedContract = DeployedContract(
          actionEventAbi,
          EthereumAddress.fromHex(contract),
        );
        BigInt tmp = BigInt.from(double.parse(params["value"].toString()) * pow(10, 18));
        transaction = Transaction.callContract(
            contract: deployedContract,
            function: deployedContract.function(params["function"]),
            parameters: parameters,
            nonce: nonce,
            from: EthereumAddress.fromHex(params["from"]),
            value: params["value"] != null ? EtherAmount.fromBigInt(EtherUnit.wei, tmp) : EtherAmount.fromBase10String(EtherUnit.gwei, '0')
        );
      } else {
        BigInt tmp = BigInt.from(double.parse(params["value"].toString()) * pow(10, 18));
        transaction = Transaction(
          from: EthereumAddress.fromHex(params["from"]),
          to: EthereumAddress.fromHex(params["to"]),
          nonce: nonce,
          value: params["value"] != null ? EtherAmount.fromBigInt(EtherUnit.wei, tmp) : EtherAmount.fromBase10String(EtherUnit.gwei, '0'),
        );
      }
      Uint8List uint8list = await client.signTransaction(credentials, transaction, chainId: chainId);
      return bytesToHex(uint8list);
    } catch (e) {
      return "";
    }
  }

  static Future<String> sendTransaction(params, parameters) async {
    try {
      Credentials credentials = EthPrivateKey.fromHex(params["privateKey"]);
      String contract = params["contract"];
      Transaction transaction = Transaction();
      EtherAmount gasPrice = await getGasPrice();
      int nonce = await getTransactionCount(params["from"]);
      if (contract.isNotEmptyString()) {
        final DeployedContract deployedContract = DeployedContract(
          actionEventAbi,
          EthereumAddress.fromHex(contract),
        );
        BigInt tmp = BigInt.from(double.parse(params["value"].toString()) * pow(10, 18));
        transaction = Transaction.callContract(
            contract: deployedContract,
            function: deployedContract.function(params["function"]),
            parameters: parameters,
            nonce: nonce,
            from: EthereumAddress.fromHex(params["from"]),
            value: params["value"] != null ? EtherAmount.fromBigInt(EtherUnit.wei, tmp) : EtherAmount.fromBase10String(EtherUnit.gwei, '0')
        );
      } else {
        BigInt tmp = BigInt.from(double.parse(params["value"].toString()) * pow(10, 18));
        transaction = Transaction(
          from: EthereumAddress.fromHex(params["from"]),
          to: EthereumAddress.fromHex(params["to"]),
          nonce: nonce,
          value: params["value"] != null ? EtherAmount.fromBigInt(EtherUnit.wei, tmp) : EtherAmount.fromBase10String(EtherUnit.gwei, '0'),
        );
      }
      String result = await client.sendTransaction(credentials, transaction, chainId: chainId);
      return result;
    } catch (e) {
      return "";
    }
  }
}
