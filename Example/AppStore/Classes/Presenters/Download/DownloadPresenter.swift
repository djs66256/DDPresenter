// MIT License
// 
// Copyright (c) 2024 Daniel
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import DDPresenter
import Service
import Combine

protocol DownloadViewDelegate: AnyObject {
    func downloadViewDidTap(_ view: DownloadViewable)
}

protocol DownloadViewable {
    var delegate: DownloadViewDelegate? { set get }
    var state: DownloadViewState { set get }
}

struct DownloadViewState: ViewState {
    public enum State {
        case startDownload
        case pending
        case downloading
        case downloaded
    }
    var state: State = .startDownload
    var progress: Double = 0
}

class DownloadPresenter<R: Identifiable, V>: ViewStatePresenter<DownloadView, DownloadViewState>, DownloadViewDelegate {
    typealias View = DownloadView
    typealias ViewState = DownloadViewState
    
    var resource: R? {
        didSet {
            updateState()
        }
    }
    
    var downloadService: DownloadService? {
        getService(DownloadService.self)
    }
    
    private var cancelables: [AnyCancellable] = []
    
    override func onAttachToRoot(_ presenter: RootViewPresentable) {
        super.onAttachToRoot(presenter)
        
        updateState()
    }
    
    private func updateState() {
        if let resource, let downloadService {
            if let _ = downloadService.findDownloadedValue(resource: resource, resultType: V.self) {
                setState {
                    $0.state = .downloaded
                }
            }
            else if let task = downloadService.findRunningTask(resource: resource, resultType: V.self) {
                setState {
                    $0.state = .downloading
                    $0.progress = task.progress
                }
                observeTask(task)
            }
            else {
                setState {
                    $0.state = .startDownload
                }
            }
        }
    }
    
    override func onDetachFromRoot(_ presenter: RootViewPresentable) {
        super.onDetachFromRoot(presenter)
        
        cancelables.removeAll()
    }
    
    override func onBindView(_ view: View) {
        super.onBindView(view)
        
         view.delegate = self
    }
    
    override func onUnbindView() {
        super.onUnbindView()
        
         view?.delegate = nil
    }
    
    override func onUpdate(view: View, context: ViewUpdateContext) {
        super.onUpdate(view: view, context: context)
        
        view.state = state
    }
    
    func downloadViewDidTap(_ view: DownloadViewable) {
        switch state.state {
        case .downloaded:
            break
        case .downloading:
            if let resource {
                downloadService?.findRunningTask(resource: resource, resultType: V.self)?.cancel()
            }
        case .startDownload:
            if let resource {
                if let task = downloadService?.download(resource: resource, resultType: V.self) {
                    setState {
                        $0.state = .downloading
                        $0.progress = task.progress
                    }
                    observeTask(task)
                }
            }
            else {
                fatalError("Resource MUST not be nil.")
            }
        case .pending:
            if let resource {
                downloadService?.findRunningTask(resource: resource, resultType: V.self)?.resume()
            }
        }
    }
    
    private func observeTask(_ task: DownloadTask<V>) {
        cancelables.removeAll()
        
        task.$completion.sink { [weak self] result in
            guard let self else { return }
            setState {
                switch result {
                case .success(_):
                    $0.state = .downloaded
                case .failure(_):
                    $0.state = .startDownload
                case .none:
                    break
                }
                $0.progress = 0
            }
            cancelables.removeAll()
        }.store(in: &cancelables)
        
        task.$progress.sink { [weak self] progress in
            guard let self else { return }
            setState {
                $0.progress = task.progress
            }
        }.store(in: &cancelables)
    }
}
