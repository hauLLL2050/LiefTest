#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#import <Foundation/Foundation.h>
#include <LIEF/LIEF.h>
#import <LIEF/MachO.hpp>
#import <LIEF/logging.hpp>
#define quickmode 0


using namespace LIEF;

int main(int argc, char **argv) {
    if (argc != 3)
    {
        NSLog(@"Usage: <Input Binary> <Output Binary>");
        return -1;
    }
    char* cLibName = argv[1];
    char* cBinName = argv[2];

    NSLog(@"lib:%s   binName:%s",cLibName, cBinName);
        NSString* strBinName = [NSString stringWithCString:cBinName encoding:NSUTF8StringEncoding];
        NSString* strBinNamePatched = [strBinName stringByAppendingString:@"_patched"];
        const char* cPatchedName = [strBinNamePatched UTF8String];
        NSLog(@"step1");
        LIEF::Logger::set_level(LIEF::LOGGING_LEVEL::LOG_GLOBAL);
        LIEF::Logger::enable();
        
#if quickmode
    MachO::ParserConfig config = MachO::ParserConfig::quick();
        std::unique_ptr<LIEF::MachO::FatBinary> binaries{MachO::Parser::parse(cBinName, config)};
#else
    MachO::ParserConfig config = MachO::ParserConfig::deep();
        std::unique_ptr<LIEF::MachO::FatBinary> binaries{MachO::Parser::parse(cBinName)};
#endif
        NSLog(@"step2");
        MachO::Binary& binary = binaries->back();
        NSLog(@"step3");
        binary.remove_signature();
        binary.add_library(cLibName);
        NSLog(@"step4");
        binary.write(cPatchedName);
        NSLog(@"step5");
    
    
//    BOOL ret = [fileMgr isExecutableFileAtPath:strBinNamePatched];
//    if(!ret)
//    {
//        int childId = fork();
//        if(childId < 0)
//        {
//            NSLog(@"create chmod process failed");
//            return -1;
//        }
//        if(childId > 0)
//        {
//            NSLog(@"fork to chmod,parent pid:%d",getpid());
//            waitpid(childId, NULL, 0);
//            BOOL ret1 = [fileMgr isExecutableFileAtPath:strBinNamePatched];
//            NSLog(@"after chmod,bin execute status:%hhd",ret1);
//        }
//        else
//        {
//            // 设置可执行程序权限
//            NSLog(@"chmod process created,pid:%d",getpid());
//            const char *injectCmd = "/bin/chmod";
//            char *argTemp[] = {"chmod", "+x", (char*)cPatchedName, NULL};
//            char *envpTemp[] = {0, NULL};
//            execve(injectCmd, argTemp, envpTemp);
//        }
//    }
    return 1;
}
