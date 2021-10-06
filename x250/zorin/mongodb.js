db.createUser(
	{
		user: "farmcrash",
		pwd: "farmcrash",
		roles: [
			{ role: "readWrite", db: "farmcrash" }
		]
	}
)
