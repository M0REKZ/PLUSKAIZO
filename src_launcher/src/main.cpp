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
#include <iostream>
#include <ctime>

sol::state GlobalLuaState;
char* Path = nullptr;

int cpp_kaizo_create_directory(const char* filepath);
sol::table cpp_kaizo_list_items_in_path(const char* path);
void cpp_kaizo_set_current_directory(const char* filepath);
void cpp_kaizo_game_frame_sleep(int ms);
void cpp_kaizo_set_vsync(int vsync);
bool cpp_kaizo_can_render();

void init_launcher()
{

    // Initialize the Lua state
    GlobalLuaState.open_libraries();
    //GlobalLuaState["PLUSKAIZO_LAUNCHER_PATH"] = Path;

    GlobalLuaState["cpp_kaizo_create_directory"] = &cpp_kaizo_create_directory;
    GlobalLuaState["cpp_kaizo_list_items_in_path"] = &cpp_kaizo_list_items_in_path;
    GlobalLuaState["cpp_kaizo_set_current_directory"] = &cpp_kaizo_set_current_directory;
    GlobalLuaState["cpp_kaizo_game_frame_sleep"] = &cpp_kaizo_game_frame_sleep;
    GlobalLuaState["cpp_kaizo_set_vsync"] = &cpp_kaizo_set_vsync;
    GlobalLuaState["cpp_kaizo_can_render"] = &cpp_kaizo_can_render;
    
}

int main()
{
    init_launcher();

    try
    {
        GlobalLuaState.safe_script_file("main_notlove.lua");
    }
    catch( const sol::error& e ) {
		std::cout << "an expected error has occurred: " << e.what() << std::endl;
	}
    return 0;
}

//functions that are missing in lua but are needed for PLUSKAIZO
//TODO: prefix with cpp_kaizo in both lua and main.cpp

int cpp_kaizo_create_directory(const char *dir) {
    char tmp[256];
    char *p = NULL;
    size_t len;
    int result;

    snprintf(tmp, sizeof(tmp),"%s",dir);
    len = strlen(tmp);
    if (tmp[len - 1] == '/' || tmp[len - 1] == '\\')
        tmp[len - 1] = 0;
    for (p = tmp + 1; *p; p++)
        if (*p == '/' || *p == '\\') {
            *p = 0;
        #ifdef _WIN32
            result = mkdir(tmp);
        #else
            result = mkdir(tmp, S_IRWXU);
        #endif
            *p = '/';

            if (result != 0 && errno != EEXIST)
                return result;
        }
#ifdef _WIN32
    return mkdir(tmp);
#else
    return mkdir(tmp, S_IRWXU);
#endif
}

void cpp_kaizo_set_current_directory(const char* filepath)
{
    chdir(filepath);
}

sol::table cpp_kaizo_list_items_in_path(const char *path)
{
    sol::table result = GlobalLuaState.create_table();
    try
    {
        int i = 0;

        for (const auto & entry : std::filesystem::directory_iterator(path))
        {
            i++;
            result[i] = entry.path().filename().string();
        }
    }
    catch(const std::exception& e)
    {
        std::cerr << e.what() << '\n';
    }
    return result;
}

timespec prevtime = {0,0};

void cpp_kaizo_game_frame_sleep(int ms)
{
    if(ms < 0)
        return;

    if(prevtime.tv_nsec == 0)
    {
        timespec_get(&prevtime,TIME_UTC);
        return;
    }

    //custom sleep function
    //it will check the amount of time passed since we last sleeped
    //if not enough time passed, we sleep the rest of time
    //otherwise we dont sleep because we are delayed

    ms -= 1; //decrease 1

    timespec nexttime = {0,0};
    timespec_get(&nexttime,TIME_UTC);
    timespec shouldtime = {0,0};
    shouldtime.tv_nsec = prevtime.tv_nsec + ms * 1000000;

    if(shouldtime.tv_nsec > nexttime.tv_nsec)
    {
        timespec sleeptime;
        sleeptime.tv_sec = 0;
        sleeptime.tv_nsec = (shouldtime.tv_nsec - nexttime.tv_nsec);
        nanosleep(&sleeptime,nullptr);
        timespec_get(&prevtime,TIME_UTC); //update timer
    }
    else
    {
        prevtime.tv_nsec += ms * 1000000; //dont sleep but advance the timer
    }
}

int kaizo_vsync_delay = 0;
clock_t lastrender = 0;

void cpp_kaizo_set_vsync(int vsync)
{
    if(vsync <= 0)
    {
        kaizo_vsync_delay = 0;
        return;
    }
    kaizo_vsync_delay = (CLOCKS_PER_SEC/vsync)-(int)(CLOCKS_PER_SEC/1000)*26;
}

bool cpp_kaizo_can_render()
{
    if(kaizo_vsync_delay == 0)
        return true;

    if(lastrender == 0)
    {
        lastrender = clock();
        return true;
    }

    clock_t nextrender = clock();

    if(lastrender + kaizo_vsync_delay > nextrender)
    {
        return false;
    }
    else
    {
        lastrender = clock();
        return true;
    }

}
