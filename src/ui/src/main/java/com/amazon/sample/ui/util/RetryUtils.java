/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package com.amazon.sample.ui.util;

import java.net.ConnectException;
import java.time.Duration;
import lombok.extern.slf4j.Slf4j;
import reactor.util.retry.Retry;
import reactor.util.retry.RetryBackoffSpec;

@Slf4j
public class RetryUtils {

  private static final Integer MAX_RETRY_ATTEMPTS = 3;
  private static final Integer MIX_RETRY_BACKOFF = 1000;

  protected RetryUtils() {
    throw new UnsupportedOperationException();
  }

  public static RetryBackoffSpec apiClientRetrySpec(String description) {
    return Retry.backoff(
      MAX_RETRY_ATTEMPTS,
      Duration.ofSeconds(MIX_RETRY_BACKOFF)
    )
      .filter(throwable -> throwable instanceof ConnectException)
      .doBeforeRetry(context -> log.warn("Retrying {}", description));
  }
}
