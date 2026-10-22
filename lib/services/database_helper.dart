class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper();

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return instance;
  }
}
