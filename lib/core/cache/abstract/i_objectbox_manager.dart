abstract class IObjectboxManager<T> {
  Future<void> create();
  void close();
  bool save();
  bool delete(int userID);
  bool update(int userID, String updatedUserName);
  void get();
  void removeAll();
}
