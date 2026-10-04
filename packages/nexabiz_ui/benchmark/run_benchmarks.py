#!/usr/bin/env python3
import subprocess
import re
import statistics
import sys
import json
import time

def run_benchmark(device, target, runs=5):
    all_runs = []
    
    for i in range(1, runs + 1):
        print(f"[{device}] Starting run {i}/{runs}...", file=sys.stderr)
        cmd = [
            "/home/hosam/Downloads/flutter-sdk/flutter/bin/flutter",
            "run",
            "--profile",
            "--no-pub",
            "-d", device,
            "-t", target
        ]
        
        proc = subprocess.Popen(
            cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True
        )
        
        bench_data = {}
        complete = False
        
        for line in proc.stdout:
            # Look for BENCH lines
            m = re.search(r'BENCH case=([a-zA-Z0-9_\. ]+) wall_us=(\d+) frames=(\d+) build_us=([0-9,]+) raster_us=([0-9,]*)', line)
            if m:
                case_name = m.group(1).strip()
                wall_us = int(m.group(2))
                frames = int(m.group(3))
                build_us = [int(x) for x in m.group(4).split(',') if x]
                raster_us = [int(x) for x in m.group(5).split(',') if x] if m.group(5) else []
                
                max_build_ms = max(build_us) / 1000.0 if build_us else 0.0
                max_raster_ms = max(raster_us) / 1000.0 if raster_us else 0.0
                wall_ms = wall_us / 1000.0
                
                bench_data[case_name] = {
                    'wall_ms': wall_ms,
                    'frames': frames,
                    'max_build_ms': max_build_ms,
                    'max_raster_ms': max_raster_ms,
                    'raw_build_us': build_us,
                    'raw_raster_us': raster_us,
                }
            if 'BENCH complete' in line:
                print(f"[{device}] Run {i} completed benchmark execution.", file=sys.stderr)
                complete = True
                try:
                    proc.stdin.write('q\n')
                    proc.stdin.flush()
                except Exception:
                    pass
                break
        
        try:
            proc.wait(timeout=10)
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait()
            
        if complete and bench_data:
            all_runs.append(bench_data)
        else:
            print(f"[{device}] Run {i} failed to complete properly.", file=sys.stderr)
            
        time.sleep(2)
        
    return all_runs

def compute_stats(all_runs):
    # Collect cases
    if not all_runs:
        return {}
        
    cases = list(all_runs[0].keys())
    stats = {}
    
    for case in cases:
        build_vals = [run[case]['max_build_ms'] for run in all_runs if case in run]
        raster_vals = [run[case]['max_raster_ms'] for run in all_runs if case in run]
        wall_vals = [run[case]['wall_ms'] for run in all_runs if case in run]
        
        def s(arr):
            if not arr:
                return {'min': 0, 'max': 0, 'mean': 0, 'median': 0, 'stdev': 0}
            return {
                'min': min(arr),
                'max': max(arr),
                'mean': statistics.mean(arr),
                'median': statistics.median(arr),
                'stdev': statistics.stdev(arr) if len(arr) > 1 else 0.0,
                'samples': len(arr),
            }
            
        stats[case] = {
            'max_build_ms': s(build_vals),
            'max_raster_ms': s(raster_vals),
            'wall_ms': s(wall_vals),
        }
        
    return stats

def main():
    target = "packages/nexabiz_ui/benchmark/profile_baseline.dart"
    
    # Run Linux
    print("=== RUNNING LINUX PROFILE BENCHMARK (5 RUNS) ===")
    linux_runs = run_benchmark("linux", target, runs=5)
    linux_stats = compute_stats(linux_runs)
    with open("linux_benchmark_results.json", "w") as f:
        json.dump({'runs': linux_runs, 'stats': linux_stats}, f, indent=2)
    print("Saved linux_benchmark_results.json")
    
    # Run Android
    print("=== RUNNING ANDROID PROFILE BENCHMARK (5 RUNS) ===")
    android_runs = run_benchmark("R5CN219FC7T", target, runs=5)
    android_stats = compute_stats(android_runs)
    with open("android_benchmark_results.json", "w") as f:
        json.dump({'runs': android_runs, 'stats': android_stats}, f, indent=2)
    print("Saved android_benchmark_results.json")

if __name__ == "__main__":
    main()
