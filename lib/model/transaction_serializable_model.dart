abstract class TransactionSerializable with TransactionSerializableMixin {
  const TransactionSerializable();
}

mixin TransactionSerializableMixin {
  Iterable<int> serialize([final TransactionSerializableConfig? config]);

  Iterable<int> serializeMessage();
}

class TransactionSerializableConfig {
  const TransactionSerializableConfig({
    this.requireAllSignatures = true,
    this.verifySignatures = true,
  });

  final bool requireAllSignatures;

  final bool verifySignatures;
}
