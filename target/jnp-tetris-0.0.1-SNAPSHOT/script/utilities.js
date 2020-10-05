function generateId() {
	//const randomString = new Date().getTime().toString() + Math.random().toString(16).substr(2, 6);
	//return CryptoJS.SHA256(randomString).substr(0, 6);
	return Math.random().toString(16).substr(2, 6);
}
