package com.example.call_tracking

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.util.Log

class LocationDbHelper(context: Context) :
    SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        private const val TAG = "LocationDbHelper"
        private const val DATABASE_NAME = "location_tracking.db"
        private const val DATABASE_VERSION = 1

        const val TABLE_NAME = "locations"
        const val COLUMN_ID = "id"
        const val COLUMN_LATITUDE = "latitude"
        const val COLUMN_LONGITUDE = "longitude"
        const val COLUMN_ACCURACY = "accuracy"
        const val COLUMN_TIMESTAMP = "timestamp"

        @Volatile
        private var instance: LocationDbHelper? = null

        fun getInstance(context: Context): LocationDbHelper {
            return instance ?: synchronized(this) {
                instance ?: LocationDbHelper(context.applicationContext).also { instance = it }
            }
        }
    }

    override fun onCreate(db: SQLiteDatabase) {
        val createTableQuery = """
            CREATE TABLE $TABLE_NAME (
                $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COLUMN_LATITUDE REAL NOT NULL,
                $COLUMN_LONGITUDE REAL NOT NULL,
                $COLUMN_ACCURACY REAL NOT NULL,
                $COLUMN_TIMESTAMP INTEGER NOT NULL
            )
        """.trimIndent()
        db.execSQL(createTableQuery)
        Log.d(TAG, "Database table created: $TABLE_NAME")
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS $TABLE_NAME")
        onCreate(db)
    }

    @Synchronized
    fun insertLocation(latitude: Double, longitude: Double, accuracy: Float, timestamp: Long): Long {
        val db = writableDatabase
        val values = ContentValues().apply {
            put(COLUMN_LATITUDE, latitude)
            put(COLUMN_LONGITUDE, longitude)
            put(COLUMN_ACCURACY, accuracy.toDouble())
            put(COLUMN_TIMESTAMP, timestamp)
        }
        val id = db.insert(TABLE_NAME, null, values)
        Log.d(TAG, "Inserted location ID $id: Lat=$latitude, Lng=$longitude, Acc=$accuracy, Time=$timestamp")
        return id
    }

    @Synchronized
    fun getLastLocation(): Map<String, Any>? {
        val db = readableDatabase
        val cursor = db.rawQuery(
            "SELECT * FROM $TABLE_NAME ORDER BY $COLUMN_ID DESC LIMIT 1",
            null
        )
        return cursor.use { c ->
            if (c.moveToFirst()) {
                val map = HashMap<String, Any>()
                map["id"] = c.getLong(c.getColumnIndexOrThrow(COLUMN_ID))
                map["latitude"] = c.getDouble(c.getColumnIndexOrThrow(COLUMN_LATITUDE))
                map["longitude"] = c.getDouble(c.getColumnIndexOrThrow(COLUMN_LONGITUDE))
                map["accuracy"] = c.getDouble(c.getColumnIndexOrThrow(COLUMN_ACCURACY))
                map["timestamp"] = c.getLong(c.getColumnIndexOrThrow(COLUMN_TIMESTAMP))
                map
            } else {
                null
            }
        }
    }

    @Synchronized
    fun getAllLocations(): List<Map<String, Any>> {
        val list = ArrayList<Map<String, Any>>()
        val db = readableDatabase
        val cursor = db.rawQuery(
            "SELECT * FROM $TABLE_NAME ORDER BY $COLUMN_ID DESC",
            null
        )
        cursor.use { c ->
            while (c.moveToNext()) {
                val map = HashMap<String, Any>()
                map["id"] = c.getLong(c.getColumnIndexOrThrow(COLUMN_ID))
                map["latitude"] = c.getDouble(c.getColumnIndexOrThrow(COLUMN_LATITUDE))
                map["longitude"] = c.getDouble(c.getColumnIndexOrThrow(COLUMN_LONGITUDE))
                map["accuracy"] = c.getDouble(c.getColumnIndexOrThrow(COLUMN_ACCURACY))
                map["timestamp"] = c.getLong(c.getColumnIndexOrThrow(COLUMN_TIMESTAMP))
                list.add(map)
            }
        }
        return list
    }

    @Synchronized
    fun clearLocations(): Int {
        val db = writableDatabase
        val count = db.delete(TABLE_NAME, null, null)
        Log.d(TAG, "Cleared $count records from database")
        return count
    }
}
