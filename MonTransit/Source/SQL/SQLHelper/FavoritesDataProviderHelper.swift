//
//  FavoritesDataProviderHelper.swift
//  MonTransit
//
//  Created by Thibault on 16-01-20.
//  Copyright © 2016 Thibault. All rights reserved.
//


import UIKit
import SQLite

class FavoritesDataProviderHelper {

    private let favorites = Table("favorite")
    
    private let id        = Expression<Int>("_id")
    private let route_id  = Expression<Int>("route_id")
    private let trip_id   = Expression<Int>("trip_id")
    private let stop_id   = Expression<Int>("stop_id")
    private let folder_id = Expression<Int>("folder_id")
    
    init() {
        
    }
    
    func retrieveFavorites(iId:Int, iType:SQLProvider.DatabaseType) -> [FavoriteObject]
    {
        
        let wFavorites = try! SQLProvider.sqlProvider.favoriteDatabase(iId).prepare(favorites.order(route_id))
        var wFavoritesList = [FavoriteObject]()
        
        for wFav in wFavorites
        {
            wFavoritesList.append(FavoriteObject(iId: wFav.get(id), iRouteId: wFav.get(route_id), iTripId: wFav.get(trip_id), iStopId: wFav.get(stop_id), iFolderId: wFav.get(folder_id), iProviderType: iType, iAgencyId: iId))
        }
        
        return wFavoritesList
    }
    
    func addFavorites(iFav:FavoriteObject, iId:Int) -> Int
    {
        do {
            let rowid = try SQLProvider.sqlProvider.favoriteDatabase(iId).run(
                favorites.insert(route_id <- iFav.getRouteId(), trip_id <- iFav.getTripId(), stop_id <- iFav.getStopId(), folder_id <- iFav.getFolderId())
                )
            return Int(rowid)
        }
        catch {
            return 0
        }
    }
    
    func removeFavorites(iFav:FavoriteObject, iId:Int) -> Bool
    {
        do {
            let wFav = favorites.filter(route_id == iFav.getRouteId() && trip_id == iFav.getTripId() && stop_id == iFav.getStopId() && folder_id == iFav.getFolderId())
            if try SQLProvider.sqlProvider.favoriteDatabase(iId).run(wFav.delete()) > 0 {
                
                return true
            }
            else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func favoriteExist(iFav:FavoriteObject, iId:Int) -> Bool
    {
        // check if this favorite existe
        let wFav = favorites.filter(route_id == iFav.getRouteId() && trip_id == iFav.getTripId() && stop_id == iFav.getStopId() && folder_id == iFav.getFolderId())
        let wFavorites = SQLProvider.sqlProvider.favoriteDatabase(iId).scalar((wFav).count)
        
         return wFavorites > 0 ? true:false

    }
}
