package com.bcunning.services.impl;

import com.bcunning.services.ITransactionService;
import org.springframework.web.bind.annotation.PostMapping;

public class TransactionService implements ITransactionService {
    @PostMapping
    public String processNewTransaction(String input) {
        return null;
    }
}
