String formatString(String original, {maxLength = 30}) {
  var result = original;
  if (original.length < maxLength) {
    result += ' ' * (maxLength - original.length);
  }

  return result;
}
