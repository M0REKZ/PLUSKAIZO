/*
    PLUSKAIZO
    Copyright (c) Benjamín Gajardo All rights reserved

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#include <unistd.h> 
#include <sys/stat.h>
#include <sol/sol.hpp>
#include <filesystem>

sol::state GlobalLuaState;
char* Path = nullptr;

extern int create_directory(const char* filepath);
extern sol::table list_items_in_path(const char* path);
extern void set_current_directory(const char* filepath);

void init_launcher()
{

    // Initialize the Lua state
    GlobalLuaState.open_libraries();
    //GlobalLuaState["PLUSKAIZO_LAUNCHER_PATH"] = Path;

    GlobalLuaState["create_directory"] = &create_directory;
    GlobalLuaState["list_items_in_path"] = &list_items_in_path;
    GlobalLuaState["set_current_directory"] = &set_current_directory;
    
}

int main()
{
    init_launcher();

    GlobalLuaState.script_file("main_notlove.lua");


    return 0;
}

//functions that are missing in lua

int create_directory(const char* filepath)
{
    #ifdef _WIN32
    return mkdir(filepath);
    #else
    return mkdir(filepath, 0755);
    #endif
}

void set_current_directory(const char* filepath)
{
    chdir(filepath);
}

sol::table list_items_in_path(const char *path)
{
    sol::table result = GlobalLuaState.create_table();
    int i = 0;

    for (const auto & entry : std::filesystem::directory_iterator(path)) {
        i++;
        result[i] = entry.path().filename().string();
    }

    std::string str;

    for(int i = 1; i < 4; i++)
    {
        str = result[i];
        printf("%s\n",str.c_str());
    }

    return result;
}
